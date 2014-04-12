#!/usr/bin/env ruby
# TaskWarrior Progress Status
require 'json'

def parse_task_logs(json_logs)
  JSON.parse "[#{json_logs}]"
  #Enclose in brackets because TaskWarrior prints an array of objects
  #but does not enclose them in brackets
end

def count_tasks_by_project(task_list)
  project_count = {}
  task_list.each do |task|
    project = task['project']
    project = "No Project" if project.nil?
    project = project.split(".")[0]
    project_count[project] = 0 unless project_count.has_key? project
    project_count[project] += 1
  end
  project_count.each_pair do |k,v|
    project_count[k] = v.to_f / task_list.length
  end
end

def sort_projects_by_count(project_count)
  (project_count.sort_by {|_key, value| value}).reverse
end

def spacer_factory(left_padding_length)
  lambda {|max|
    " " * (max - left_padding_length)
  }
end

def output_results(projects_by_count)
  max = 0
  projects_by_count.each do |item|
    item << spacer_factory(item[0].length)
    max = item[0].length if max < item[0].length
  end
  projects_by_count.each do |item|
    puts "#{item[0]}:" + item[2].call(max) + "#{(item[1] * 100).to_i}%"
  end
end

json_logs = `task export end.after:-3wk end.before:tomorrow`
task_list = parse_task_logs(json_logs)
project_count = count_tasks_by_project(task_list)
projects_by_count = sort_projects_by_count(project_count)
output_results(projects_by_count)
