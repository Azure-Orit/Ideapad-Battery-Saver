dependencies = [
    posix,
    dependency('gtk+-3.0'),
    meson.get_compiler('c').find_library('m', required: true)
]

sources = files('main.vala')
install_data('../data/BatterySaver-launcher', install_dir : '/usr/local/bin')
install_data('../data/icon.svg', install_dir : get_option('datadir') / 'BatterySaver')
install_data('../data/BatterySaver.desktop', install_dir : '/usr/share/applications')
install_data('../data/BatterySaver.policy', install_dir : '/usr/share/polkit-1/actions/')

executable('BatterySaver', sources, dependencies:dependencies, install:true)
