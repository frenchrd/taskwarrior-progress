#!/usr/bin/env ruby
# TaskWarrior Progress Status
require 'date'
require 'json'

def taskwarrior_date(date)
  "#{date.month}/#{date.day}/#{date.year}"
end

def taskwarrior_completed_within(date1,date2)
  before = taskwarrior_date(date2)
  after  = taskwarrior_date(date1)
  `task export end.before:#{before} end.after:#{after} status:completed`
end

def parse_task_logs(json_logs)
  JSON.parse "[#{json_logs}]"
  #Enclose in brackets because TaskWarrior prints an array of objects
  #but does not enclose them in brackets
end

def count_tasks_by_project(task_list)
  project_count = {}
  task_list.each do |task|
    project = task['project']
    project_count[project] = 0 unless project_count.has_key? project
    project_count[project] += 1
  end
  project_count
end

def sort_projects_by_count(project_count)
  (project_count.sort_by {|_key, value| value}).reverse
end

def output_results(projects_by_count)
  projects_by_count.each do |item|
    puts "#{item[0]}: #{item[1]}"
  end
end

today = DateTime.now
three_weeks_ago = today - 21
json_logs = taskwarrior_completed_within(three_weeks_ago, today)
task_list = parse_task_logs(json_logs)
project_count = count_tasks_by_project(task_list)
projects_by_count = sort_projects_by_count(project_count)
output_results(projects_by_count)