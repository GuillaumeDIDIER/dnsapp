# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>
#Handful methods for the search engine

module SearchHelper

  #Builds options from fields, field names and request params
  def search_options(fields, names, params)
    options = []

    for i in 0..(fields.length - 1)
      hash = { :field => fields[i], :name => names[i], :value => params[fields[i].to_sym] }
      options.insert( -1, hash )
    end

    return options
  end

  #Builds a hash (:title, :conditions)
  #where :conditions is ready to pass to a find method
  def searching_for(options, initial_conditions=[""])
    first = true
    title = ""
    conditions = [""]
    if !initial_conditions.blank?
      conditions = initial_conditions
      conditions[0] = "#{initial_conditions[0]} and (" unless initial_conditions[0] == ""
    else
      initial_conditions = [""]
    end

    for i in 0..(options.length - 1)
      if !options[i][:value].blank?
        like = "%#{options[i][:value]}%"
        
        if first
          title = "Résultats pour #{options[i][:name]} ~ #{options[i][:value]}"
          conditions[0] += "#{options[i][:field]} like ?"
          conditions.insert( -1, like )
          first = false
        else
          title += " et #{options[i][:name]} ~ #{options[i][:value]}"
          conditions[0] += " and #{options[i][:field]} like ?"
          conditions.insert( -1, like )
        end
      end
    end

    if first
      title = ""
      conditions = initial_conditions
    end

    return { :title => title, :conditions => conditions }
  end

end
