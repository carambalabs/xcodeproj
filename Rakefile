#!/usr/bin/rake

require 'semantic'
require 'fileutils'
require 'git'

DESTINATION = "platform=iOS Simulator,name=iPhone 6,OS=11.3"
XCODEGEN_VERSION = "1.8.0"
SOURCERY_VERSION = "0.13.0"

def git
  Git.open(".")
end

def any_git_changes?
  !git.status.changed.empty?
end

def command?(name)
  `which #{name}`
  $?.success?
end

def build
  sh "swift build"
end

def test_swift
  sh "xcodebuild -project xcodeproj.xcodeproj -scheme xcodeproj-Package -only-testing:xcodeprojTests -config Debug test -enableCodeCoverage YES"
end

def test_swift_integration
  sh "swift test --filter xcodeprojIntegrationTests"
end

def format
  sh "swiftformat ."
end

def current_version
  last_tag = `git describe --tags $(git rev-list --tags --max-count=1)`
  Semantic::Version.new last_tag
end

def next_version(type)
  current_version.increment! type
end

def commit_changes_and_push(tag)
  git.add "."
  git.commit "Bump version to #{tag.to_string}"
  if tag
    git.add_tag(tag.to_string)
  end
  git.push('origin', "refs/tags/#{tag.to_string}")
end

def is_macos
  !ENV["TRAVIS_OS_NAME"] || ENV["TRAVIS_OS_NAME"] == "osx"
end

def print(message)
  puts "> #{message}"
end

desc "Executes all the validation steps for CI"
task :ci do
  print "Generate Xcode project"
  sh "swift package generate-xcodeproj"
  print "Linting project"
  sh "swiftlint" if is_macos
  print "Building the project"
  build()
  print "Executing tests"
  test_swift()
  if git.current_branch == "integration" || ENV["TRAVIS_BRANCH"] == "integration"
    print "Executing integration tests"
    test_swift_integration()
  end
end

desc "Branches off master into integration and pushes it to origin (only executable from master)"
task :deploy_to_integration do
   if git.current_branch == "master" || ENV["TRAVIS_BRANCH"] == "master"
    token = ENV["GITHUB_TOKEN"]
    return abort("GITHUB_TOKEN environment variable is missing") unless token
    git.add_remote("origin-travis", "https://#{token}@github.com/tuist/xcodeproj.git")
    git.push("origin-travis", "master:integration")
   end
end

desc "Runs sourcery"
task :sourcery do
  sh "sourcery --config sourcery.yml"
end

task :format do
  format
end
