module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    coffee: {
      compile: {
        files: {
          "build/test/specs.js": ["test/*.coffee"],
          "build/src/ng-quick-date.js": ["src/*.coffee"],
          "build/demo/demo.js": ["demo/*.coffee"]
        }
      }
    },
    stylus: {
      compile: {
        files: {
          "build/src/ng-quick-date.css": ["src/ng-quick-date.styl"],
          "build/src/ng-quick-date-default-theme.css": ["src/ng-quick-date-default-theme.styl"],
          "build/demo/demo.css": ["demo/*.styl"]
        }
      }
    },
    watch: {
      scripts: {
        files: ['**/*.coffee', '**/*.styl'],
        tasks: ['coffee', 'stylus'],
        options: {
          debounceDelay: 250,
        },
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-stylus');
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.registerTask('default', ['coffee', 'stylus', 'watch']);
};
