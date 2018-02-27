# Jenkins2

[![Gem Version](https://badge.fury.io/rb/jenkins2.svg)](https://badge.fury.io/rb/jenkins2)

Jenkins2 gem is a command line interface and API client for Jenkins 2 CI Server. This gem is
tested with latest Jenkins LTS. (See the [CHANGELOG](CHANGELOG.md) for exact versions.)

## Features available

### Global

- Jenkins version
- Quiet Down
- Cancel Quiet Down
- Safe Restart
- Immediate Restart

### Users / People

- Get authenticated user (who-am-i)

### Node / Slave / Computer

- Create slave from config.xml
- Delete slave
- Toggle slave offline / online
- Launch slave agent
- Disconnect slave
- Get slave's config.xml
- List \[online\] slaves
- Get slave(s) states

### Plugins

- List installed plugins
- Install a plugin and its dependencies from update center (providing a short name e.g.
thinBackup).
- Install a plugin either from a file or an URL. Dependencies are not installed!
- Show plugin information
- Uninstall a plugin

### Credentials

- Create username with password credentials (Requires credentials plugin on Jenkins)
- Create ssh username with private key credentials (Requires ssh-credentials plugin on Jenkins)
- Create secret string credentials (Requires plain-credentials plugin on Jenkins)
- Create secret file credentials (Requires plain-credentials plugin on Jenkins)
- Get credentials by id
- Delete credentials
- List credentials in particular store and domain

### Views

- List views
- Get view configuraiton xml
- Update view configuraiton xml
- Create View
- Delete View
- Add job to view
- Remove job from view

### Jobs

- List jobs
- Create job from config.xml or by copying another one
- Set (Update) job's config.xml
- Get job's config.xml
- Delete job
- Enable, disable job
- Run build (with parameters, if required)

## Installation

```sh
$ gem install jenkins2
```

## Usage

Either run it from command line:

```sh
$ jenkins2 -s http://jenkins.example.com offline-node -n mynode
$ jenkins2 --help # => for help and list of available commands
$ jenkins2 --help <command> # => for help on particular command
```

Or use it in your ruby code:

```ruby
require 'jenkins2'

jc = Jenkins2.connect(server: 'http://jenkins.example.com', user: 'admin', key:  'mysecretkey')
jc.version
jc.computer('mynode').toggle_offline( 'Some reason, why' )
```

## Configuration

The gem does not require any configuration. However, if your Jenkins is secured you will have to
provide credentials with every CLI call.

```sh
$ jenkins2 -s http://jenkins.example.com -u admin -k mysecretkey offline-node -n mynode
```

This can be avoided by creating a yaml configuration file like this

```yaml
---
:server: http://jenkins.example.com
:user: admin
:key: mysecretkey
:verbose: 3
:log: /var/log/jenkins2.log
```

and putting global options there. Jenkins will not read the file unless you use `-c` or
`--config-file` switches. If you use the switch, but omit the file path, the gem will look for
`.jenkins2.conf` in current directory.

This way the above mentioned command is much shorter

```sh
$ jenkins2 -c offline-node -n mynode # => -c switch tells Jenkins2 to read .jenkins2.conf file
```

## License

MIT - see the accompanying [LICENSE](LICENSE) file for details.

## Changelog

To see what has changed in recent versions see the [CHANGELOG](CHANGELOG.md).
Jenkins2 gem follows the [Semantic Versioning Policy](http://guides.rubygems.org/patterns).

## Contributing

Additional commands and bugfixes are welcome! Please fork and submit a pull request on an
individual branch per change. The project has a script folder which is inspired by GitHub Script
["Scripts To Rule Them All"] (https://github.com/github/scripts-to-rule-them-all) pattern.

### Bootstrap

After cloning the project, run:

```sh
$ script/bootstrap
```

to download gem and other dependencies (currently tested only on ubuntu xenial).

### Tests

The project is expected to be heavily tested :) with unit and integratin tests.
Integration tests are run against a Jenkins server. Currently Jenkins server is set up in docker
container. To run all the tests (unit and integration ) type:

```sh
$ script/test
```

This will start Jenkins in docker container, run the tests and then kill the container. If you
want to just start the Jenkins in docker and then may be run tests several times against it, you
can do the following:

```sh
$ source script/jenkins_start # start jenkins
$ rake test:all # run all tests
```
Then, when you have finished running tests, run `script/jenkins_kill` to stop Jenkins in docker.

If you want to run just unit tests, you can do it through rake task:

```sh
$ rake test:unit
```
provided you have already installed all the dependences (see [jenkins2.gemspec](jenkins2.gemspec)
-> development\_dependencies or run [bootstrap script](script/bootstrap)).

### Continuous Integration

The project uses Bitbucket Pipelines as CI environment. You can check out
[bitbucket-pipelines.yml](bitbucket-pipelines.yml) for the exact script.

Also there is a [Jenkinsfile](Jenkinsfile) for quick and easy integration with Jenkins Pipelines.
Unfortunately it is outdated now, but it can be still used as an example to start from.
