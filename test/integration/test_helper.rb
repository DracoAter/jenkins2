# frozen_string_literal: true

require 'simplecov'
require 'minitest/autorun'

require_relative '../../lib/jenkins2'

# Setup subject just once
module Minitest
	class Test
		@@opts = {
			server: ENV['JENKINS2_SERVER'],
			user: ENV['JENKINS2_USER'],
			key: ENV['JENKINS2_KEY'],
			# Tests can be super verbose
			verbose: 3,
			# but should write into some file
			log: 'test/integration.log'
		}
		@@subj = Jenkins2.connect @@opts

		# Install plugins, required by tests.
		PLUGINS = %w[command-launcher ssh-credentials plain-credentials cloudbees-folder
			role-strategy].freeze
		@@subj.plugins.install PLUGINS

		# Make sure plugins are installed.
		Jenkins2::Util.wait(max_wait_minutes: 2) do
			@@subj.plugins(depth: 1).plugins.select do |p|
				PLUGINS.include?(p.shortName) and p.active
			end.size == PLUGINS.size
		end

		# Change security settings. Enable role-strategy
		json = %({'useSecurity': {'disableRememberMe': true, 'realm': {'value': '1',
'stapler-class': 'hudson.security.HudsonPrivateSecurityRealm',
'$class': 'hudson.security.HudsonPrivateSecurityRealm', 'allowsSignup': false},
'authorization': {'value': '5',
'stapler-class': 'com.michelin.cio.hudson.plugins.rolestrategy.RoleBasedAuthorizationStrategy',
'$class': 'com.michelin.cio.hudson.plugins.rolestrategy.RoleBasedAuthorizationStrategy'}},
'': '0', 'markupFormatter': {'stapler-class': 'hudson.markup.EscapedMarkupFormatter',
'$class': 'hudson.markup.EscapedMarkupFormatter'}, 'slaveAgentPort': {'value': '50000',
'type': 'disable'}, 'agentProtocol': 'JNLP4-connect',
'hudson-security-csrf-GlobalCrumbIssuerConfiguration': {'csrf': {'issuer': {'value': '0',
'stapler-class': 'hudson.security.csrf.DefaultCrumbIssuer',
'$class': 'hudson.security.csrf.DefaultCrumbIssuer', 'excludeClientIPFromCrumb': false}}},
'jenkins-CLI': {'enabled': false}, 'jenkins-model-DownloadSettings': {'useBrowser': false},
'jenkins-security-s2m-MasterKillSwitchConfiguration': {'masterToSlaveAccessControl': {}},
'org-jenkinsci-main-modules-sshd-SSHD': {'port': {'value': '', 'type': 'disable'}}})
		@@subj.connection.post('configureSecurity/configure', nil, json: json)

		# Restart Jenkins before running the tests, to make sure all pending changes are applied.
		# For example uninstalling plugin, requires restart.
		# Required to make sure you can run tests as many times as you need in a row.
		@@subj.restart!

		# Make sure Jenkins is ready and listening
		Jenkins2::Util.wait(max_wait_minutes: 2){ @@subj.version }
	end
end
