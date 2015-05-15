require 'rails/engine'
require "action_controller/railtie"
require 'off_the_record'

class TestModel < OffTheRecord::Base
  attribute :first
  attribute :second

  attribute :defaulted, default: :default

  attr_accessor :bypassing

  attribute :boolean, type: :boolean
  attribute :date, type: :date
  attribute :date_time, type: :date_time
  attribute :float, type: :float
  attribute :integer, type: :integer
  attribute :string, type: :string

  validates :first, presence: true
  validates :bypassing, numericality: true
end

module Nesting
  class NestedModel < OffTheRecord::Base
    attribute :first
  end
end

class UserSignin < OffTheRecord::Base
  attribute :first

  def self.model_name_base
    'Signin'
  end
end

describe "initialization" do
  it "can be initialized without arguments" do
    model = TestModel.new
    expect(model).to be_an_instance_of(TestModel)
    expect(model.first).to be_nil
  end

  it "can be initialized with nil" do
    model = TestModel.new(nil)
    expect(model).to be_an_instance_of(TestModel)
    expect(model.first).to be_nil
  end

  it "can be initialized with an attribute hash" do
    model = TestModel.new(first: 1)
    expect(model.first).to be 1
    expect(model.second).to be_nil
  end
end

describe "setting an attribute" do
  subject(:model) { TestModel.new }

  it "can be read back afterwards" do
    model.first = 5
    expect(model.first).to be 5
    expect(model.attributes[:first]).to be 5
    expect(model.attributes["first"]).to be 5
  end
end

describe "query methods" do
  subject(:model) { TestModel.new }

  it "returns false when value is unset, nil or false" do
    expect(model).not_to be_first
    model.first = nil
    expect(model).not_to be_first
    model.first = false
    expect(model).not_to be_first
  end

  it "returns false when value is a string with only spaces or tabs" do
    model.first = " \t"
    expect(model).not_to be_first
  end
end

describe "defaults" do
  subject(:model) { TestModel.new }

  it "returns the default value when not set" do
    expect(model.defaulted).to be :default
  end

  it "returns nil when value set to nil" do
    model.defaulted = nil
    expect(model.defaulted).to be_nil
  end
end

describe "mass assignment" do
  def described_class; TestModel; end
  subject(:model) { described_class.new }

  it "does mass assignment upon #assign_attributes" do
    model.assign_attributes(first: 1, second: 2)
    expect(model.second).to be 2
  end

  context "with a params object as inside a controller" do
    def controller_parameters
      ActionController::Parameters.new({
        :first => 1,
        :second => 2,
      })
    end

    context "with unpermitted parameters" do
      it "prevents assignment by raising an exception when using assign_attributes" do
        expect {
          model.assign_attributes(controller_parameters)
        }.to raise_exception(ActiveModel::ForbiddenAttributesError)
      end

      it "prevents assignment by raising an exception when passing to .new" do
        expect {
          described_class.new(controller_parameters)
        }.to raise_exception(ActiveModel::ForbiddenAttributesError)
      end
    end

    context "with permitted parameters" do
      def controller_parameters
        super.permit(:first, :second)
      end

      it "performs the assigment when #assign_attributes is called" do
        model.assign_attributes(controller_parameters)
        expect(model.first).to be 1
      end

      it "performs the assigment when .new is called" do
        model = described_class.new(controller_parameters)
        expect(model.first).to be 1
      end
    end
  end
end

describe "type casting" do
  def described_class; TestModel; end
  subject(:model) { described_class.new }

  context "with type string" do
    it "reads value back as string" do
      model.string = 6
      expect(model.string).to eql("6")
    end
  end

  context "with type boolean" do
    it "reads true and '1' as true" do
      model.boolean = true
      expect(model.boolean).to be true
      model.boolean = "1"
      expect(model.boolean).to be true
    end

    it "reads false and '0' as false" do
      model.boolean = false
      expect(model.boolean).to be false
      model.boolean = "0"
      expect(model.boolean).to be false
    end
  end

  context "with type date" do
    it "reads a Date back as-is" do
      date = Time.now.to_date
      model.date = date
      expect(model.date).to eql(date)
    end

    it "converts a Time to a Date" do
      time = Time.now
      model.date = time
      expect(model.date).to be_an_instance_of(Date)
      expect(model.date.day).to be time.day
    end

    it "converts a nicely formatted String to a Date" do
      date = Time.now.to_date
      model.date = date.to_s
      expect(model.date).to eql(date)
    end

    it "converts gibberish to nil" do
      model.date = "X"
      expect(model.date).to be_nil
    end
  end

  context "with type date_time" do
    it "reads a DateTime back as-is" do
      date_time = Time.now.to_datetime
      model.date_time = date_time
      expect(model.date_time).to eql(date_time)
    end

    it "converts a Date to a DateTime" do
      date = Time.now.to_date
      model.date_time = date
      expect(model.date_time).to be_an_instance_of(DateTime)
      expect(model.date_time.to_date).to eql(date)
    end

    it "converts a nicely formatted String to a DateTime" do
      date_time = Time.now.to_datetime
      date_time = date_time.beginning_of_minute # escape the sub-second conversion error
      model.date_time = date_time.to_s
      expect(model.date_time).to eql(date_time)
    end

    it "converts gibberish to nil" do
      model.date_time = "X"
      expect(model.date_time).to be_nil
    end
  end

  context "with type float" do
    it "reads a Float back as-is" do
      pi = Math::PI
      model.float = pi
      expect(model.float).to eql(pi)
    end

    it "converts a string to a float" do
      model.float = "1.3"
      expect(model.float).to eql(1.3)
    end

    it "converts gibberish to nil" do
      model.float = "X"
      expect(model.float).to be_nil
    end
  end

  context "with type integer" do
    it "reads a Fixnum back as-is" do
      model.integer = 1
      expect(model.integer).to be 1
    end

    it "converts a string to a Fixnum" do
      model.integer = "17"
      expect(model.integer).to be_an_instance_of(Fixnum)
      expect(model.integer).to eql(17)
    end

    it "converts gibberish to nil" do
      model.integer = "X"
      expect(model.integer).to be_nil
    end
  end

  context "with type string" do
    it "reads a String back as-is" do
      model.string = "hello world"
      expect(model.string).to eql("hello world")
    end

    it "converts a number to a String" do
      model.string = 1
      expect(model.string).to eql("1")
    end
  end
end

describe "validations" do
  def described_class; TestModel; end
  subject(:model) { described_class.new }

  before do
    model.bypassing = 5 # don't trigger it's validation by accident
  end

  it "knows when it is valid" do
    model.first = "present"
    expect(model).to be_valid
  end

  it "knows when it is not valid and has an error after validation" do
    expect(model).not_to be_valid
    expect(model.errors[:first]).to include("can't be blank")
  end
end

describe "bypassing the attribute DSL" do
  def described_class; TestModel; end
  subject(:model) { described_class.new }

  it "can yet be used in combination with mass assignment on initialization" do
    model = described_class.new(bypassing: 5)
    expect(model.bypassing).to be 5
  end

  it "can yet be used in combination with mass assignment on #assign_attributes" do
    model.assign_attributes(bypassing: 5)
    expect(model.bypassing).to be 5
  end

  it "can yet be used in combination with validations" do
    model.first = "present"
    expect(model).not_to be_valid
    model.bypassing = 5
    expect(model).to be_valid
  end
end

describe "when used with form_for" do
  def described_class; TestModel; end
  subject(:model) { described_class.new }

  let(:application) do
    Class.new(Rails::Engine)
  end

  let(:view_context) do
    controller = ActionController::Base.new
    controller.request = ActionDispatch::Request.new({})
    result = controller.view_context
    result.extend ActionDispatch::Routing::PolymorphicRoutes # no idea why this is necessary
  end

  it "renders attribute values as form input values" do
    model.first = "firstvalue"
    form = view_context.form_for(model, url: "bogus") do |f|
      view_context.concat f.text_field :first
    end
    expect(form).to include('firstvalue')
  end

  it "renders form for POST method" do
    form = view_context.form_for(model, url: "bogus") do |f|
      view_context.concat f.text_field :first
    end
    expect(form).to include('method="post"')
  end

  it "renders proper input param names" do
    form = view_context.form_for(model, url: "bogus") do |f|
      view_context.concat f.text_field :first
    end
    expect(form).to include('name="test_model[first]"')
  end

  context "with a nested model" do
    subject(:model) { Nesting::NestedModel.new }

    it "renders input param names which ignore the nesting" do
      form = view_context.form_for(model, url: "bogus") do |f|
        view_context.concat f.text_field :first
      end
      expect(form).to include('name="nested_model[first]"')
    end
  end

  context "with a model providing its own model name base" do
    subject(:model) { UserSignin.new }

    it "renders input param names derived from model_name_base" do
      form = view_context.form_for(model, url: "bogus") do |f|
        view_context.concat f.text_field :first
      end
      expect(form).to include('name="signin[first]"')
    end
  end
end

