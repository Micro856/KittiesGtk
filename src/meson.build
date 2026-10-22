kittiesgtk_sources = [
  'main.vala',
  'application.vala',
  'window.vala',
]

kittiesgtk_deps = [
  config_dep,
  dependency('gtk4'),
  dependency('libadwaita-1', version: '>= 1.4'),
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
