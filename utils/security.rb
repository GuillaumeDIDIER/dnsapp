module Security

  def self.extended(base)
    @env = ENV['RAILS_ENV'] || "development"

    if base.respond_to? "security_level" and self.levels.include? base.security_level
      print "Rails env = '\033[31m#{@env}\033[0m'\n\n"
      self.level = base.security_level
      self.check
    else
      print "Pas de niveau de sécurité défini!\n"
      Kernel.exit
    end
  end

  def self.levels 
    [:none, :production_confirm, :production_deny]
  end

  def self.level
    @level
  end

  private

    def self.level=(level)
      @level = level
    end

    def self.check
      if @env == "production"
        if level == :production_confirm

          print "\033[31m *** Attention : Ce script va modifier la base de données en production *** \033[0m\n"
          print "Continuer ? (o/n) > "
          confirm = gets
          confirm = confirm.chomp

          unless confirm.match(/\Ao(ui)?\z/i)
            print "\033[31mInterrompu\033[0m\n"
            Kernel.exit
          end

        elsif level == :production_deny
            print "\033[31mScript interrompu : il est interdit de l'utiliser en production\033[0m\n"
            Kernel.exit
        end
      end
    end

end
