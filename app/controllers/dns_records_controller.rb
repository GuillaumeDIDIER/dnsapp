# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>
#So we can see all DNS Records.

class DnsRecordsController < ApplicationController

  before_filter :set_conditions_and_title, :only => :index
  before_filter :check_record, :only => [:show, :edit, :update, :destroy]

  def index
    #Request format
    format = request.format.symbol

    #Search engine
    @options = search_options(record_fields, record_field_names, search_types, params)
    hash = searching_for(@options, @conditions)
    @title = hash[:title] unless hash[:title].blank?
    @records = DnsRecord.find(:all, :conditions => hash[:conditions])

    #Pagination for html requests
    @records = @records.paginate :page => params[:page] if format == :html
  end

  def show
    @record ||= DnsRecord.find(params[:id])
    @title = "Profil : #{@record.host}.#{@record.zone}"
  end

  def new
    @record = DnsRecord.new
    @title = "Nouvel enregistrement DNS"
  end

  def edit
    @record ||= DnsRecord.find(params[:id])
    @title = "Modifier #{@record.host}.#{@record.zone}"
  end

  private

    def record_fields
      ["host", "zone", "rtype", "data"]
    end

    def record_field_names
      ["nom", "zone", "type", "données"]
    end

    def search_types
      ["like", "strict", "strict", "like"]
    end

    def set_conditions_and_title
      @conditions = [""]
      @title = "Tous les enregistrements DNS"
    end

    def check_record
    end

end
