# Cap-EC2 changelog

## 0.0.7

* Removed monkey patching of `Capistrano::TaskEnhancements` [@rjocoleman](https://github.com/rjocoleman)
* Instances don't always have a name tag, would cause `ec2:status` to blow up [@rjocoleman](https://github.com/rjocoleman)

## 0.0.6

* Unbreak listing instances

## 0.0.5

* Don't return terminated instances when looking up instances from EC2
* Fix documentation to refer to correct tag for Stages [@shaneog](https://github.com/shaneog)

## 0.0.4

* If you modified any of the tag names, the `ec2:status` table would blow up
* Fixed a bug with stages

## 0.0.3

* Rename the default tag name used for determining to 'Stages' from 'Stage'

## 0.0.2

* Allow servers to be in multiple stages

## 0.0.1

* Initial release