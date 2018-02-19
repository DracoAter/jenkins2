# Change Log

## [v1.0.0](https://bitbucket.org/DracoAter/jenkins2/commits/tag/v1.0.0) (February 19, 2018)

### Tested With

- Jenkins 2.89.4
	- ssh-credentials 1.13
	- plain-credentials 1.4
	- command-launcher 1.2

### Enhancements

- Completely refactored API and CLI.
- Log will write to stderr by default (instead of stdout).
- Can create/show/update/delete Views.
- Can create/show/update/delete Jobs.
- Can show existing Users, People.
- Can install plugin from file/url.
- Code is now checked with rubocop.
- Switched configuration file format to yaml.
- Integration tests are now run on bitbucket pipelines.

## [v0.1.0](https://bitbucket.org/DracoAter/jenkins2/commits/tag/v0.1.0) (October 11, 2017)

### Enhancements

- Support Crumbs.
- Can forcefully restart Jenkins.

## [v0.0.2](https://bitbucket.org/DracoAter/jenkins2/commits/tag/v0.0.2) (October 25, 2016)

### Enhancements

- Hopefully this gem is now usable.
- Get Jenkins version.
- Prepare for / cancel Jenkins shutdown.
- Wait for all nodes to be idle.
- Set node temporarily offline / online.
- Connect / Disconnect node.
- Wait for node to become idle, check if node is idle.
- Get node definition as XML.
- Update node definition from XML.
- Run [parameterized] build.
- List installed plugins.
- Install / uninstall a plugin by short name (i.e. ssh-credentials).
- Create username with password credential ( Requires credentials plugin on Jenkins ).
- Create ssh username with private key credential ( Requires ssh-credentials plugin on Jenkins ).
- Create secret string credential ( Requires plain-credentials plugin on Jenkins ).
- Create secret file credential ( Requires plain-credentials plugin on Jenkins ).
- Get credential by id.
- List credentials.
