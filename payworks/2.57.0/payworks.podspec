Pod::Spec.new do |spec|
    spec.name               = 'payworks'
    spec.version            = '2.57.0'
    spec.license            = { :type => 'Copyright', :text => 'Copyright (c) 2021 CyberSource Corporation. All Rights Reserved.' }
    spec.homepage           = 'https://payworks.com/developers'
    spec.authors            = { 'payworks' => 'developers@payworks.com' }
    spec.summary            = 'A delightful payment integration framework powered by payworks'
    spec.platform           = :ios, '15.0'
    spec.requires_arc       = true
    spec.source             = { :http => 'https://repo.visa.com/mpos-releases/io/payworks/mpos.ios.sdk/'+spec.version.to_s+'/mpos.ios.sdk-'+spec.version.to_s+'.zip', :sha256 => 'bd64208d8ccf1752d50d583b79eb30a015087fa4e726bd9458533e459b5e2f57' }
    spec.default_subspec       = 'default'

    spec.subspec 'mpos' do |mpos|

        mpos.subspec 'core' do |core|
            core.vendored_frameworks    = 'mpos_core.xcframework', 'core.xcframework'
            core.frameworks             = 'ExternalAccessory', 'Security', 'MobileCoreServices', 'SystemConfiguration', 'UIKit', 'Foundation', 'CoreGraphics'
            core.library                = 'icucore'
        end
    end

    spec.subspec 'default' do |default|
        default.dependency 'payworks/mpos/core'
    end


    spec.subspec 'offline' do |offline|
        offline.dependency 'payworks/mpos'
    end
end
