## 0.3.2 (unreleased)

* #assign_from_optional_params
* documentation improvements
* DEPRECATION of creation directly from attributes: the default constructor will be removed in the future
* defaulting mechanism refactored to support overriding the constructor without having to call super
  (this fixes defaulting when overriding the constructor and allows to remove the constructor param in the future)

## 0.3.1 (2015-10-22)

* Bugfix: do not assume AM models implement model_name on the instance, only on the class (needed for older Rails versions)
* documentation improvements

## 0.3.0 (2015-07-27)

* #assign_from_params
* documentation improvements

## 0.2.1 (2015-07-06)

* Bugfix: Permits#to_permit_filters now converts values from hash pairs correctly

## 0.2.0 (2015-06-23)

* nil values are no longer subject to typecasting
* New feature: from_optional_params

## 0.1.0 (2015-05-17)

Initial release.

