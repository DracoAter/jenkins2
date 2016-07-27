# Jenkins2

Jenkins2 gem is a command line interface and API client for Jenkins 2 CI Server, that can be used
either from command line or from your code.

# Installation

    gem install jenkins2

# Usage

Either run it from command line:

    jenkins2 -s http://jenkins.example.com offline-node -n mynode
    jenkins2 --help #for help and list of available commands
    jenkins2 --help <command> #for help on particular command

Or use it in your gem:

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
