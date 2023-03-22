Pod::Spec.new do |spec|
	spec.name				= 'payworks.paybutton'
	spec.version			= '2.59.0'
	spec.license			= { :type => 'Copyright', :text => 'Copyright (c) 2023 VISA Inc. All Rights Reserved.' }
    spec.homepage           = 'https://payworks.mpymnt.com/cp_payworks_portal.html'
    spec.authors            = { 'payworks' => 'developers@payworks.com' }
	spec.summary			= 'A delightful UI framework build on top of the venerated payment integration framework powered by payworks'
	spec.platform			= :ios, '15.0'
	spec.requires_arc		= true
	spec.swift_version      = '5.0'
	spec.source				= { :http => 'https://repo.visa.com/mpos-releases/io/payworks/mpos.ios.ui/'+spec.version.to_s+'/mpos.ios.ui-'+spec.version.to_s+'.zip' }
	spec.vendored_frameworks = 'mpos_ui.xcframework'

	spec.ios.dependency			'payworks/mpos/core', '2.59.0'
end
