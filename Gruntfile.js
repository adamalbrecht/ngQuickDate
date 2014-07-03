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
    less: {
      compile: {
        files: {
          "dist/ng-quick-date.css": ["src/ng-quick-date.less"],
          "dist/ng-quick-date-default-theme.css": ["src/ng-quick-date-default-theme.less"],
          "dist/ng-quick-date-plus-default-theme.css": ["src/ng-quick-date.less", "src/ng-quick-date-default-theme.less"]
        }
      }
    },
    watch: {
      scripts: {
        files: ['**/*.coffee', '**/*.less'],
        tasks: ['coffee', 'uglify', 'less'],
        options: {
          debounceDelay: 250,
        },
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.registerTask('default', ['coffee', 'uglify', 'less', 'watch']);
};
