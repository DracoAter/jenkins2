node {
	timestamps {
		withEnv(['RUBY_ENV=test']) {

			stage 'Checkout'
			checkout([$class: 'MercurialSCM', source: 'http://bitbucket.org/DracoAter/jenkins2'])

			stage 'Unit Tests'
			sh 'script/unit_test'
			junit 'test/unit/reports/*.xml'
			publishHTML(target: [allowMissing: false, alwaysLinkToLastBuild: false,
				keepAll: false, reportDir: 'test/unit/coverage', reportFiles: 'index.html',
				reportName: 'Unit Test Coverage Report'])

			stage 'Integration Tests'
			sh 'script/integration_test'
			junit 'test/integration/reports/*.xml'
			publishHTML(target: [allowMissing: false, alwaysLinkToLastBuild: false,
				keepAll: false, reportDir: 'test/integration/coverage', reportFiles: 'index.html',
				reportName: 'Integration Test Coverage Report'])

			stage 'Build Gem'
			sh 'rake gem'
			archiveArtifacts artifacts: 'pkg/jenkins2-*.gem', excludes: null, onlyIfSuccessful: true
			fingerprint 'pkg/jenkins2-*.gem'
		}
	}
}
