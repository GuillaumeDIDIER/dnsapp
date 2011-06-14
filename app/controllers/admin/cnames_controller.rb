# encoding: utf-8
include RegexHelper
# On hérite pour avoir les même méthodes privées
# Il doit aussi il y avoir un moyen de rendre ça
# plus DRY (don't repeat yourself)
class Admin::CnamesController < DomainNamesController

  skip_before_filter :correct_user
  before_filter :has_alias_privileges

  private
  
    def has_alias_privileges
      deny_access unless has_privileges?
      if privileges[:alias].nil? || privileges[:alias] == 0
        flash[:error] = "Tu n'as pas les droits sur cette ressource"
        redirect_to root_path
      end
    end


end
