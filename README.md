# OffTheRecord

OffTheRecord is a small library for creating form models for Rails applications.

Use form models in Rails whenever

* form input from a user covers multiple database models
* form input from a user contains data not intended for persistence

Features:

* Compatibility: Form models created with OffTheRecord can be used together with `form_for` and resourceful routing.
* secure mass assignment
* Declarative DSL for attributes
* type conversion
* default values
* query methods for attributes
* validations and errors

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'off_the_record'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install off_the_record

## Usage

Derive directly from `OffTheRecord::Base` and declare your attributes:

```ruby
class Signup < OffTheRecord::Base
  attribute :email_address
  attribute :initial_password
  attribute :tos_accepted, type: :boolean

  validates :tos_accepted, acceptance: true
  validates :email_address, presence: true, email: true
  validate :validate_password_strength

  def validate_password_strength
    ...
  end
end
```

You can instantiate a new record with values from a plain hash:

```ruby
Signup.new(email_address: 'example@example.com')
```

The form object class keeps track of the necessary permit filters, so you can perform
instantiation from securely filtered params like this:

```ruby
Signup.new(params.require(:signup).permit(*Signup.permit_filters)
```

Since this is a common use case and the model knows its own name, there is a shortcut for this:

```ruby
Signup.from_params(params)
```

There is also `from_optional_params` which just creates a new record in case the params key is missing.

Note there is a twist involved in the naming of the model which has effect on the form
input `name` attributes and the `action` attribute derived by `form_for` from the name of
the model: the model is treated *as if it is not nested* within a class or module. This
allows you to write down your form models right inside a controller or a service object
without excessively long naming leaking your implementation details to the front end, and
without the need for tweaking options to `form_for`. Note you will still want to use the `:url`
option in most cases.

You can implement your own attributes any time simply by defining a getter and setter.
Call `permit` to add a permit filter for your attributes:

```ruby
class MyModel < OffTheRecord::Base
  attr_accessor :array_of_strings

  permit array_of_strings: []
end
```


## Contributing

1. Fork it ( https://github.com/[my-github-username]/off_the_record/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
