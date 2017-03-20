# Cap-EC2

[![Gem Version](https://badge.fury.io/rb/cap-ec2.svg)](http://badge.fury.io/rb/cap-ec2) [![Code Climate](https://codeclimate.com/github/forward3d/cap-ec2.png)](https://codeclimate.com/github/forward3d/cap-ec2)

Cap-EC2 is used to generate Capistrano namespaces and tasks from Amazon EC2 instance tags,
dynamically building the list of servers to be deployed to.

## Notes

Cap-EC2 is only compatible with Capistrano 3.x or later; if you want the Capistrano 2.x version,
use [Capify-EC2](https://github.com/forward/capify-ec2). Note that the configuration file (`config/ec2.yml`)
is not compatible between versions either.

This documentation assumes familiarity with Capistrano 3.x.

A number of features that are in Capify-EC2 are not yet available in Cap-EC2, due to the
architectural changes in Capistrano 3.x. The following features are missing (this is not
an exhaustive list!):
* rolling deploy (this should be implemented via [SSHKit](https://github.com/capistrano/sshkit))
* ELB registration/de-registration (not widely used)
* Variables set by EC2 tags
* Connecting to instances via SSH using a convenience task

Pull requests for these would be welcomed, as would sending feedback via the Issues on this project about
features you would like.

## Installation

    gem install cap-ec2

or add the gem to your project's Gemfile.

You also need to add the gem to your Capfile:

```ruby
require "cap-ec2/capistrano"
```


## Configuration

Configurable options, shown here with defaults:

```ruby
set :ec2_config, 'config/ec2.yml'

set :ec2_project_tag, 'Project'
set :ec2_roles_tag, 'Roles'
set :ec2_stages_tag, 'Stages'

set :ec2_access_key_id, nil
set :ec2_secret_access_key, nil
set :ec2_region, %w{} # REQUIRED
set :ec2_contact_point, nil

set :ec2_filter_by_status_ok?, nil
```

#### Order of inheritance

`cap-ec2` supports multiple methods of configuration. The order of inheritance is:
YAML File > User Capistrano Config > Default Capistrano Config > ENV variables.

#### Regions

`:ec2_region` is an array of
[AWS regions](http://docs.aws.amazon.com/general/latest/gr/rande.html#ec2_region)
and is required. Only list regions which you wish to query for
instances; extra values simply slow down queries.

If `:ec2_access_key_id` or `:ec2_secret_access_key` are not set in any
configuration the environment variables `AWS_ACCESS_KEY_ID`,
`AWS_SECRET_ACCESS_KEY` and `AWS_REGION` will be checked and the
default credential load order (including instance profiles
credentials) will be honored.

#### Misc settings

* project_tag

  Cap-EC2 will look for a tag with this name when searching for instances that belong to this project.
  Cap-EC2 will look for a value which matches the :application setting in your deploy.rb.
  The tag name defaults to "Project" and must be set on your instances.

* stages_tag

  Cap-EC2 will look for a tag with this name to determine which instances belong to
  a given stage. The tag name defaults to "Stages".

* roles_tag

  Cap-EC2 will look for a tag with this name to determine which instances belong to
  a given role. The tag name defaults to "Roles".

* filter_by_status_ok?

  If this is set to `true`, then Cap-EC2 will not return instances which do not have both EC2 status
  checks as `OK`. By default this is set to `nil`, so Cap-EC2 can return you instances which don't have
  `OK` status checks. Be warned that just-launched instances take a while to start returning `OK`.

### YAML Configuration


If you'd prefer do your configuration via a YAML file `config/ec2.yml` can be used, (or an alternative name/location set via `set :ec2_config`):

If so YAML file will look like this:

```ruby
access_key_id: "YOUR ACCESS KEY"
secret_access_key: "YOUR SECRET KEY"
regions:
 - 'eu-west-1'
project_tag: "Project"
roles_tag: "Roles"
stages_tag: "Stages"
```


Your `config/ec2.yml` file can contain (`access_key_id`, `secret_access_key`, `regions`) - if a value is omitted then the order of inheritance is followed.


## Usage

Imagine you have four servers on EC2 named and tagged as follows:

<table>
  <tr>
    <td>'Name' Tag</td>
    <td>'Roles' Tag</td>
    <td>'Stages' Tag</td>
  </tr>
  <tr>
    <td>server-1</td>
    <td>web</td>
    <td>production</td>
  </tr>
  <tr>
    <td>server-2</td>
    <td>web,app</td>
    <td>production</td>
  </tr>
  <tr>
    <td>server-3</td>
    <td>app,db</td>
    <td>production</td>
  </tr>
  <tr>
    <td>server-4</td>
    <td>web,db,app</td>
    <td>staging</td>
  </tr>
</table>

Imagine also that we've called our app "testapp", as defined in `config/deploy.rb` like so:

    set :application, "testapp"

### Defining the roles in `config/deploy/[stage].rb`

To define a role, edit `config/deploy/[stage].rb` and add the following:

    ec2_role :web

Let's say we edited `config/deploy/production.rb`. Adding this configuration to the file would assign
the role `:web` to any instance that has the following properties:
* has a tag called "Roles" that contains the string "web"
* has a tag called "Project" that contains the string "testapp"
* has a tag called "Stages" that contains the current stage we're executing (in this case, "production")

Looking at the above table, we can see we would match `server-1` and `server-2`. (You can have multiple
roles in tag separated by commas.)

Now we can define the other roles:

    ec2_role :app
    ec2_role :db

In the "production" stage, the `:app` role would apply to `server-2` and `server-3`, and the `:db`
role would apply to `server-3`.

In the "staging" stage, all roles would apply *only* to `server-4`.

### Servers belonging to multiple projects

If you require your servers to have multiple projects deployed to them, you can simply specify
all the project names you want to the server to be part of in the 'Projects' tag, separated
by commas. For example, you could place a server in the `testapp` and `myapp` projects by
setting the 'Projects' tag to `testapp,myapp`.

### Servers in multiple stages

If your use-case requires servers to be in multiple stages, simply specify all the stages you want
the server to be in 'Stages' tag, separated by commas. For example, you could place a server in
the `production` and `staging` stages by setting the 'Stages' tag to `production,staging`.

### Passing options to roles

You can pass options when defining your roles. The options are *exactly* the same as the options that
the Capistrano native `role` definition takes, since they are passed straight through to Capistrano.
For example:

    ec2_role :app,
      user: 'user_name',
      ssh_options: {
        user: 'user_name', # overrides user setting above
        keys: %w(/home/user_name/.ssh/id_rsa),
        forward_agent: false,
        auth_methods: %w(publickey password)
        password: 'please use keys'
      }

See the example config files Capistrano builds for you in `config/deploy` for more details.

Note that at the moment there's no way to pass variables in from EC2 tags - but it would be
trivial to add.

### Tasks and deployment

You can now define your tasks for these roles in exactly the same way as you would if you weren't
using this gem.

### Contacting instances

By default, Cap-EC2 will attempt to communicate with the EC2 instance using the following instance
interfaces in order:

1. Public DNS (`:public_dns`)
2. Public IP (`:public_ip`)
3. Private IP (`:private_ip`)

This can be configured using the Capistrano variable `:ec2_contact_point`, and supplying one
of the above symbols. For example:

```ruby
set :ec2_contact_point, :private_ip
```

This would cause Cap-EC2 to try communicating with the instance on its private IP address. If you leave
this variable unset, the behaviour is as in previous Cap-EC2 instances (falling through the lookup list
as specified above).

## Utility tasks

Cap-EC2 adds a few utility tasks to Capistrano for displaying information about the instances that
you will be deploying to. Note that unlike Capistrano 2.x, all tasks *require* a stage.

### View instances

This command will show you information all the instances your configuration matches for a given stage.

    cap [stage] ec2:status

Example:

    $ cap production ec2:status

    Num  Name                          ID          Type      DNS              Zone        Roles         Stage
    00:  server-1-20131030-1144-0      i-abcdefgh  m1.small  192.168.202.248  us-west-2c  banana,apple  production
    01:  server-2-20131118-1839-0      i-hgfedcba  m1.small  192.168.200.60   us-west-2a  banana        production

### View server names

This command will show you the server names of the instances matching the given stage:

  cap [stage] ec2:server_names

Example:

    $ cap production ec2:server_names
    server-1-20131030-1144-0
    server-2-20131118-1839-0

### View server instance IDs

This command will show the instance IDs of the instances matching the given stage:

    cap [stage] ec2:instance_ids

Example:

    $ cap production ec2:instance_ids
    i-abcdefgh
    i-hgfedcba

## Acknowledgements

Thanks to [Rylon](https://github.com/Rylon) for maintaining Capify-EC2 and
reviewing my thought processes for this project.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
