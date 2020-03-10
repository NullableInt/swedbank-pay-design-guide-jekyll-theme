require 'nokogiri'
require 'dimensions'

plant_uml_jar_file = "./.github/scripts/plantuml.1.2020.2.jar"
diagram_directory = "assets/diagrams"

html_files = Dir[ './_site/**/*.html' ].select{ |f| File.file? f }

Dir.mkdir("./_site/#{diagram_directory}") unless File.exists?(diagram_directory)

html_files.each_with_index do |file, file_index|
  dirname = File.dirname(file)
  parsed_html = Nokogiri::HTML.parse(File.open(file, "r"))
  parsed_html.css(".language-plantUML").each_with_index do | tag, tag_index |
    uml_file_base_name = "#{File.basename(file, ".*")}_#{file_index}_#{tag_index}"
    uml_file_name = "./_site/#{diagram_directory}/#{uml_file_base_name}"
    uml_file = File.open("#{uml_file_name}.puml", "w+"){ |f| f.write(tag.text)}
    system("java -jar #{plant_uml_jar_file} -tpng #{uml_file_name}.puml") or raise "PlantUml error"
    image_node = parsed_html.create_element "img"
    image_node['src'] = "#{diagram_directory}/#{uml_file_base_name}.png"
    image_node['width'] = "#{Dimensions.width("#{uml_file_name}.png")}"
    image_node['height'] = "#{Dimensions.height("#{uml_file_name}.png")}"
    puts image_node
    tag.replace(image_node)
  end
  File.write(file, parsed_html)
end
