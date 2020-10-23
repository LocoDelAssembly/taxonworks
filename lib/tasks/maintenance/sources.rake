namespace :tw do
  namespace :maintenance do
    namespace :sources do

      require 'csl/styles'

      desc 'rewrite config/initializers/constants/_controlled_vocabularies/csl_styles.rb'
      task regenerate_csl_styles_constant: [:environment] do |t|
        p = '/config/initializers/constants/_controlled_vocabularies/csl_styles.rb'
        styles = CSL::Style.list.map{ |id| CSL::Style.load id }.reject { |s| s.bibliography.nil? }

        f = File.new(Rails.root.to_s + p, 'w:UTF-8')

        f.write  "# THIS FILE IS AUTO GENERATED, DO NOT EDIT\n"
        f.write  "CSL_STYLES = {\n"
        # !#$@# how to escape all the nastyness properly ...
        f.write  styles.inject({}){|h, a| h.merge(a.id => %Q{#{a.title}})}.collect{|k,v| '"' + k + '" => ' + '"' + v.gsub(/[\\"]/, '') + '"' }.join(",\n")
        f.write  '}'

        f.close
      end

    end
  end
end


