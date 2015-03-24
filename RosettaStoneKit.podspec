Pod::Spec.new do |s|
  s.name         = "RosettaStoneKit"
  s.version      = "1.0.1"
  s.summary      = "Magical Object Mapping framework for iOS/OS X"

  s.description  = <<-DESC
                   RosettaStoneKit is a magical Object Mapping framework.
                   It converts dictionaries and arrays of data into instances of any classes.
                   It can also convert your custom objects into dictionaries and arrays.
                   DESC

  s.homepage     = "http://endoze.github.io/RosettaStoneKit"
  s.license      = {type: "MIT", file: "LICENSE"}

  s.author             = {"Chris" => "chris@wideeyelabs.com"}
  s.social_media_url   = "https://twitter.com/endozemedia"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"

  s.source       = {git: "https://github.com/endoze/RosettaStoneKit.git", tag: "1.0.0"}
  s.source_files  = "Common", "Common/**/*.{h,m}"

  s.requires_arc = true
end
