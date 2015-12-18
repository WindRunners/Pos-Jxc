var from_submit = function () {
    var chateau_id = $('#btn_chateau_id').val();
    var table = $('#wines_table').DataTable();
    var wine_id = table.row('.selected').data();
    $.ajax({

        type: "post",
        url: "relate_wine",
        data: {wine_id: wine_id._id},
        dataType: "json",

        success: function (data) {
            $('#exampleModal').modal('hide');
            $('#resultTable').prepend("<tr><td>" + data.name + "</td><td>" + data.category + "</td><td>" + data.price + "</td>" +
                "<td>" + data.hits + "</td><td>" + data.created_at + "</td><td>" + data.status + "</td>" +
                "<td><a  class='btn btn-minier btn-danger' href='/chateaus/" + chateau_id + "/resolve_wine?wine_id=" + wine_id._id + "' data-method='delete' rel='nofollow' data-confirm='Are you sure?'>解除关联</a></td></tr>")
            alert("关联成功！");
        }, error: function (data) {
            $('#exampleModal').modal('hide');
            alert("关联失败！");
        }
    });
}