module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    coffee: {
      compile: {
        files: {
          "test/generated/specs.js": ["test/coffee/*.coffee"]
        }
      }
    },
    watch: {
      scripts: {
        files: 'test/coffee/*.coffee',
        tasks: ['coffee'],
        options: {
          debounceDelay: 250,
        },
      },
    }
  });

  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.registerTask('default', ['coffee']);
};
