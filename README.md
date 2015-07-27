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

### Initialization from ActionController parameters

The form object class keeps track of the necessary permit filters, so you could perform
instantiation from securely filtered params like this:

```ruby
Signup.new(params.require(:signup).permit(*Signup.permit_filters)
```

Since an `OffTheRecord` model knows its name as well as its parameters, there is a shortcut for this:

```ruby
Signup.from_params(params)
```

In cases where `params[:signup]` might be missing, you can use

```ruby
Signup.from_optional_params(params)
```

There is also assignment as an instance method:

```ruby
signup.assign_from_params(params)
```

Note that `OffTheRecord` overrides default model naming because the default use case is
having the model declared right inside the controller:

```ruby
class SignupController < ApplicationController
  ...
  class Signup < OffTheRecord::Base
    ...
  end
end
```

Without tweaking the model naming, the params key for the signup params would be `:signup_controller_signup` (leaking implementation details), instead the nesting is not taken into account for the naming, so the param key is really `:signup`. With `.from_params` e.a. however, you won't need to touch these details.

### Control over permit filters

Call `permit` on the form model class to override the permit filter for an attribute:

```ruby
class MyModel < OffTheRecord::Base
  attribute :array_of_strings

  permit array_of_strings: []
end
```

This must happen _after_ the `attribute` call.

### Custom attributes

You can implement your own attributes any time simply by defining a getter and setter.
You have to declare a permit filter for each (and possibly implement type conversion in
a custom setter).

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
