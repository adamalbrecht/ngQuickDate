module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    coffee: {
      compile: {
        files: {
          "spec/build/specs.js": ["spec/*.coffee"],
          "dist/fd-quick-moment.js": ["src/*.coffee"]
        }
      }
    },
    uglify: {
      my_target: {
        files: {
          "dist/fd-quick-moment.min.js": "dist/fd-quick-moment.js"
        }
      }
    },
    stylus: {
      compile: {
        files: {
          "dist/fd-quick-moment.css": ["src/fd-quick-moment.styl"],
          "dist/fd-quick-moment-default-theme.css": ["src/fd-quick-moment-default-theme.styl"]
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
