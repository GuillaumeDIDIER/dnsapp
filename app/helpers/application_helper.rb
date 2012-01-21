# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>

module ApplicationHelper

  # Return a title on a per-page basis.
  def title
    base_title = "DnsApp"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end

  #Truncate string to fit <num> caracters
  def trunc(string, num)
    if string.length > num
      string[0..(num-4)] + "..."
    else
      string
    end
  end

end
