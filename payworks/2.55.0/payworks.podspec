Pod::Spec.new do |spec|
    spec.name               = 'payworks'
    spec.version            = '2.55.0'
    spec.license            = { :type => 'Copyright', :text => 'Copyright (c) 2021 CyberSource Corporation. All Rights Reserved.' }
    spec.homepage           = 'https://payworks.com/developers'
    spec.authors            = { 'payworks' => 'developers@payworks.com' }
    spec.summary            = 'A delightful payment integration framework powered by payworks'
    spec.platform           = :ios, '10.0'
    spec.requires_arc       = true
    spec.source             = { :http => 'https://repo.visa.com/mpos-releases/io/payworks/mpos.ios.sdk/'+spec.version.to_s+'/mpos.ios.sdk-'+spec.version.to_s+'.zip', :sha256 => '16af7011f9f1db60a681cffe27a0e560d52d5e27edd16f7fa56980138930ffce' }
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
        offline.dependency 'couchbase-lite-ios', '~> 1.4.1'
        offline.dependency 'payworks/mpos'
    end
end
