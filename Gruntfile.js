module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    coffee: {
      compile: {
        files: {
          "spec/build/specs.js": ["spec/*.coffee"],
          "dist/ng-quick-date.js": ["src/*.coffee"]
        }
      }
    },
    uglify: {
      my_target: {
        files: {
          "dist/ng-quick-date.min.js": "dist/ng-quick-date.js"
        }
      }
    },
    stylus: {
      compile: {
        files: {
          "dist/ng-quick-date.css": ["src/ng-quick-date.styl"],
          "dist/ng-quick-date-default-theme.css": ["src/ng-quick-date-default-theme.styl"]
        }
      }
    },
    watch: {
      scripts: {
        files: ['**/*.coffee', '**/*.styl'],
        tasks: ['coffee', 'uglify', 'stylus'],
        options: {
          debounceDelay: 250,
        },
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-stylus');
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.registerTask('default', ['coffee', 'uglify', 'stylus', 'watch']);
};
