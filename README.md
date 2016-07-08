# Jenkins

Jenkins gem is a command line interface and API client for Jenkins CI Server, that can be used
either from command line or from your code.

# Installation

    gem install jenkins

# Usage

Either run it from command line:

    jenkins -s http://jenkins.example.com offline-node mynode
    jenkins --help #for help and list of available commands
    jenkins --help <command> #for help on particular command

Or use it in your gem:

    require 'jenkins'
    Jenkins::Client.new( :server => 'http://jenkins.example.com', :node => 'mynode' ).offline_node

# License

MIT - see the accompanying [LICENSE](LICENSE) file for details.

# Changelog

To see what has changed in recent versions see the [CHANGELOG](CHANGELOG.md).
Jenkins Tips gem follows the [Semantic Versioning Policy](http://guides.rubygems.org/patterns).

# Contributing

Additional commands and bugfixes are welcome! Please fork and submit a pull request on an
individual branch per change.
