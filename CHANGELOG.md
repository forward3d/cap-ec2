# Cap-EC2 changelog

## 0.0.11

* Allow instances to have multiple projects deployed to them. [@rsslldnphy](https://github.com/rsslldnphy)
* Fix the way instance tag matching works; the previous regex was not sufficient to ensure 
  absolute matching of a given tag. [@rsslldnphy](https://github.com/rsslldnphy)

## 0.0.10

* Allow configurable setting of the EC2 contact point [@christianblunden](https://github.com/christianblunden)

## 0.0.9

* Handle no configured regions, (or specifically nil).

## 0.0.8

* Made `config/ec2.yml` optional, set all options by Capistrano variable. [@rjocoleman](https://github.com/rjocoleman)
* Remove requirement for default region to be set. [@rjocoleman](https://github.com/rjocoleman)

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
