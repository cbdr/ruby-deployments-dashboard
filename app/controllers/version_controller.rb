require 'json'
require 'httparty'

class VersionController < ApplicationController
  def index
    @thispull = version_info
    @commits = version_commits
    find_jobsearch_changes find_gemfile_changes
  end

  private

  def version_info
    pullurl = 'https://api.github.com/repos/cbdr/CB-Mobile/pulls/' + params['id'] + '?access_token=15d13e3ca0aa8c8e8f5d9174d48e1b995b5d7450'
    pullresp = HTTParty.get(pullurl, :headers => {"User-Agent" => 'ruby'})
    thispull = JSON.parse(pullresp.body)
  end

  def version_commits
    url = 'https://api.github.com/repos/cbdr/CB-Mobile/pulls/' + params['id'] + '/commits?access_token=15d13e3ca0aa8c8e8f5d9174d48e1b995b5d7450'
    resp = HTTParty.get(url, :headers => {"User-Agent" => 'ruby'})
    commits = JSON.parse(resp.body)
  end

  def find_gemfile_changes
    url2 = 'https://api.github.com/repos/cbdr/CB-Mobile/pulls/' + params['id'] + '/files?access_token=15d13e3ca0aa8c8e8f5d9174d48e1b995b5d7450'
    resp2 = HTTParty.get(url2, :headers => {"User-Agent" => 'ruby'})
    @files = JSON.parse(resp2.body)

    patches_to_parse = []
    refs = []
    @files.each do |file|
      patches_to_parse << file["patch"] if file["filename"] = "Gemfile"
    end

    patches_to_parse.each do |patch|
      refs.concat patch.scan(/ref: ?'(\w+)'/) if patch.nil? == false
    end
    refs
  end

  def find_jobsearch_changes(refs)


    dates = []
    refs.each do |sha|
      url3 = 'https://api.github.com/repos/cbdr/JobSearch/commits/' + sha[0].to_s + '?access_token=15d13e3ca0aa8c8e8f5d9174d48e1b995b5d7450'
      resp3 = HTTParty.get(url3, :headers => {"User-Agent" => 'ruby'})
      commit = JSON.parse(resp3.body)
      dates << DateTime.parse(commit["commit"]["author"]["date"]) if commit["commit"].nil? == false
    end
    @jobsearch_changes = []

    if dates.count >= 2
      max_date = dates.max
      min_date = dates.min

      url4 = 'https://api.github.com/repos/cbdr/JobSearch/pulls?state=closed&base=master&access_token=15d13e3ca0aa8c8e8f5d9174d48e1b995b5d7450'
      resp4 = HTTParty.get(url4, :headers => {"User-Agent" => 'ruby'})
      jobsearch_pulls = JSON.parse(resp4.body)


      jobsearch_pulls.each do |jspull|
        closed_date = DateTime.parse(jspull["closed_at"])
        hashy = {:title => jspull["title"],:url => jspull["html_url"],:user => jspull["user"]}
        @jobsearch_changes << hashy  if closed_date <= max_date && closed_date >= min_date
      end
    end
  end
end
