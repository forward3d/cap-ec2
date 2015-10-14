# Cap-EC2 changelog

## 1.0.1

* Adds the ability set a session token (needed for federated AWS access)

## 1.0.0

Cap-EC2 is pretty stable, and the rate of PRs has decreased, so I've
decided to bump the version to 1.0.0.

* Remove the require of `capistrano/setup`, so that people can make
  use of `capistrano-multiconfig`. [@ashleybrown](https://github.com/ashleybrown)

## 0.0.19

* Stop using the `colored` gem, switch to `colorize` instead. [@freakphp][https://github.com/freakphp]

## 0.0.18

* Update gemspec to explicitly use the AWS v1 SDK. [@Tomtomgo](https://github.com/Tomtomgo)
* Fix available roles for newer Capistrano versions. [@AmirKremer](https://github.com/AmirKremer)

## 0.0.17

* Provide access to EC2 server tags within Capistrano recipes [@eightbitraptor](https://github.com/eightbitraptor)
* Fix sorting of servers when there is no Name tag [@johnf](https://github.com/johnf)

## 0.0.16

* Don't colorize status table output if STDOUT is not a TTY. [@jcoglan](https://github.com/jcoglan)

## 0.0.15

* Add `ec2_filter_by_status_ok?` to filter out instances that aren't returning `OK`
  for their EC2 status checks. [@tomconroy](https://github.com/tomconroy)

## 0.0.14

* Fix issue when tag was present in EC2 but had no value. [@tomconroy](https://github.com/tomconroy)

## 0.0.13

* Use AWS.memoize to speed up communication with AWS [@cheald](https://github.com/cheald)

## 0.0.12

* Use the instance's named state for searching for instances, rather than the code [@ronny](https://github.com/ronny)

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
