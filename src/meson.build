kittiesgtk_sources = [
  'main.vala',
  'application.vala',
  'window.vala',
  'backend.vala',
  'gary_api.vala',
  'rory_api.vala'
]

kittiesgtk_deps = [
  config_dep,
  dependency('gtk4'),
  dependency('libadwaita-1', version: '>= 1.4'),
  dependency('libsoup-3.0'),
  dependency('json-glib-1.0'),
  dependency('gio-2.0'),
  dependency('glycin-2'),
  dependency('glycin-gtk4-2'),
]

blueprints = custom_target('blueprints',
  input: files(
    'window.blp',
    'shortcuts-dialog.blp'
  ),
  output: '.',
  command: [find_program('blueprint-compiler'), 'batch-compile', '--minify', '@OUTPUT@', '@CURRENT_SOURCE_DIR@', '@INPUT@'],
)

kittiesgtk_sources += gnome.compile_resources('kittiesgtk-resources',
  'kittiesgtk.gresource.xml',
  c_name: 'kittiesgtk',
  dependencies: [blueprints],
)

executable('kitties', kittiesgtk_sources,
  dependencies: kittiesgtk_deps,
  include_directories: config_inc,
       install: true,
)
