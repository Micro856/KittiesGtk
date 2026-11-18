conf = configuration_data()
conf.set('bindir', get_option('prefix') / get_option('bindir'))
conf.set('APP_ID', app_id)

desktop_file = i18n.merge_file(
        input: configure_file(
        	input: 'io.github.Micro856.KittiesGtk.desktop.in.in',
        	output: 'io.github.Micro856.KittiesGtk.desktop.in',
        	configuration: conf,
        	),
       output: '@0@.desktop'.format(app_id),
         type: 'desktop',
       po_dir: '../po',
      install: true,
  install_dir: get_option('datadir') / 'applications'
)

desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
  test('Validate desktop file', desktop_utils, args: [desktop_file])
endif

appstream_file = i18n.merge_file(
        input: configure_file(
        	input: 'io.github.Micro856.KittiesGtk.metainfo.xml.in.in',
        	output: 'io.github.Micro856.KittiesGtk.metainfo.xml.in',
        	configuration: conf,
        	),
       output: '@0@.metainfo.xml'.format(app_id),
       po_dir: '../po',
      install: true,
  install_dir: get_option('datadir') / 'metainfo'
)

appstreamcli = find_program('appstreamcli', required: false, disabler: true)
test('Validate appstream file', appstreamcli,
     args: ['validate', '--no-net', '--explain', appstream_file])

install_data('io.github.Micro856.KittiesGtk.gschema.xml',
  install_dir: get_option('datadir') / 'glib-2.0' / 'schemas'
)

compile_schemas = find_program('glib-compile-schemas', required: false, disabler: true)
test('Validate schema file',
     compile_schemas,
     args: ['--strict', '--dry-run', meson.current_source_dir()])

configure_file(
  input: 'io.github.Micro856.KittiesGtk.service.in',
  output: '@0@.service'.format(app_id),
  configuration: conf,
  install_dir: get_option('datadir') / 'dbus-1' / 'services'
)

subdir('icons')
