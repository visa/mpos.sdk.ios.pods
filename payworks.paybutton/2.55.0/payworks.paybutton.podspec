Pod::Spec.new do |spec|
	spec.name				= 'payworks.paybutton'
	spec.version			= '2.55.0'
	spec.license			= { :type => 'Copyright', :text => 'Copyright (c) 2021 CyberSource Corporation. All Rights Reserved.' }
	spec.homepage			= 'https://www.payworks.com/developers'
    spec.authors            = { 'payworks' => 'developers@payworks.com' }
	spec.summary			= 'A delightful UI framework build on top of the venerated payment integration framework powered by payworks'
	spec.platform			= :ios, '10.0'
	spec.requires_arc		= true
	spec.swift_version      = '5.0'
	spec.source				= { :http => 'https://repo.visa.com/mpos-releases/io/payworks/mpos.ios.ui/'+spec.version.to_s+'/mpos.ios.ui-'+spec.version.to_s+'.zip', :sha256 => '22aa0f7670a602298ebfc57ecef8e5f37c1c56e549ee88ca224af6969166b529' }
	spec.vendored_frameworks = 'mpos_ui.xcframework'

	spec.ios.dependency			'payworks/mpos/core', '2.55.0'
end
