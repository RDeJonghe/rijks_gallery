$(function() {

  $("#deleter").click(function(event) {
    event.preventDefault();
    event.stopPropagation();

    var ok = confirm("Are you sure?")
    if (ok) {
      this.click();
    }
  });

});

// testing 