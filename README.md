# Jenkins2

Jenkins2 gem is a command line interface and API client for Jenkins 2 CI Server.

# Features available
## Global
- Get Jenkins version
- Prepare for shutdown
- Cancel shutdown
- Wait for all nodes to be idle

## Node
- Set node temporarily offline / online
- Connect / Disconnect node
- Wait for node to become idle
- Get node definition as XML
- Update node definition from XML

## Job
- Run [parameterized] build

## Plugin
- Install a plugin by short name or by uploading a \*.jpi file

## Credentials
- Create username / password credentials
- Create ssh username with private key credentials
- Create secret sting credentials
- Get credentials by id
- List credentials

# Installation

    gem install jenkins2

# Configuration

The gem does not require any configuration. However, if your Jenkins is secured you will have to
provide credentials with every CLI call.

    jenkins2 -s http://jenkins.example.com -u admin -k mysecretkey offline-node -n mynode

This can be avoided by creating a json configuration file like this

    {
      "server": "http://jenkins.example.com",
      "user": "admin",
      "key": "mysecretkey"
    }

By default Jenkins2 expects this file to be at ~/.jenkins2.json, but you can provide your own path
with --config-file switch. This way the above mentioned command will be much shorter.

    jenkins2 -c offline-node -n mynode # => -c switch tells Jenkins2 to read configuration file

# Usage

Either run it from command line:

    jenkins2 -s http://jenkins.example.com offline-node -n mynode
    jenkins2 --help # => for help and list of available commands
    jenkins2 --help <command> # => for help on particular command

Or use it in your ruby code:

    require 'jenkins2'
    jc = Jenkins2::Client.new( server: 'http://jenkins.example.com' )
    jc.version
    jc.offline_node( node: 'mynode' )

# License

MIT - see the accompanying [LICENSE](LICENSE) file for details.

# Changelog

To see what has changed in recent versions see the [CHANGELOG](CHANGELOG.md).
Jenkins2 gem follows the [Semantic Versioning Policy](http://guides.rubygems.org/patterns).

# Contributing

Additional commands and bugfixes are welcome! Please fork and submit a pull request on an
individual branch per change.
