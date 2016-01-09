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

  validates :tos_accepted, acceptance: { :accept => true }
  validates :email_address, presence: true, email: true
  validate :validate_password_strength

  def validate_password_strength
    ...
  end
end
```

Off the bat, instances have getters and setters for the declared attributes,
and you can assign a hash of attributes using `assign_attributes`.
Type conversion happens when attributes are read:

```
signup = Signup.new
signup.assign_attributes(email_address: 'johndoe@example.com', tos_accepted: "1")
signup.tos_accepted # => true
```

### ActionController parameters and `strong_parameter`-like safety

The form object class keeps track of the necessary permit filters, and it knows its
own name and can look for its attributes in an ActionController params object.
(Note that the param name is also simplified, see below)

Thus, to assign from a params object, you only have to write

```ruby
signup.assign_from_params(params)
```

instead of

```ruby
signup.assign_attributes(params.require(:signup).permit(*Signup.permit_filters))
```

Sometimes, the object's attributes may be completely absent from the params object.
In that case you can write

```ruby
signup.assign_from_optional_params(params)
```

which will not alter `signup` if `params.key?(:signup)` is false.

NOTE constructing directly from params is DEPRECATED.

### Creation from ActionController parameters

Most of the time you will not need to do custom initialization and setup before the assignment
from params. There are handy shortcuts for these cases:

```ruby
Signup.from_params(params)
Signup.from_optional_params(params)
```

### Simplified param keys / model naming

`OffTheRecord` overrides default model naming because the default use case is
having the model declared right inside the controller:

```ruby
class SignupController < ApplicationController
  ...
  class Signup < OffTheRecord::Base
    ...
  end
end
```

Without tweaking the model naming, the params key for the signup params would be
`:signup_controller_signup` (thus leaking implementation details)
Instead, nesting is not taken into account for the generated model name. The param
key in the above example therefore is simply `:signup`.
You don't have to worry about these details if you use the `from_(optional_)params` methods.

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
