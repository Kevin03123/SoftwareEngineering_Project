<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SubjectManagement.aspx.cs" Inherits="KYUTES.SubjectManagement" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
    <style>
        .display {
            text-align: center;
            font-size: larger;
        }
    </style>
    <link href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.min.css" rel="stylesheet" />

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.min.js"></script>
    <script src="Scripts/Common.js"></script>

    <script>
        $(document).ready(function () {
            Init_DataList();
            SetListener();
        });

        function SetListener() {
            $('#btnCreate').click(function () {
                let flag = confirm('確定要新增嗎？');
                if (!flag) { return false; }

                let SubjectName = $('#SubjectName').val();
                CreateSubject(SubjectName);
            });
        } // end SetListener

        function CreateSubject(SubjectName) {
            let Method = 'CreateSubject';
            let url = `/api/_SubjectManagement.ashx?Method=${Method}`;
            let Parameters = { SubjectName: SubjectName };

            let result = CallAPI(url, Parameters);
            let isSuccess = result['isSuccess'];
            let Msg = result['Msg'];

            if (isSuccess) {
                alert('新增成功');
                location.reload();
            } else {
                if (Msg == 'logout') {
                    GoToDefaultPage();
                } else {
                    alert(Msg);
                }
            }

        } // end CreateSubject

        // 建立 DataTable 標頭跟標尾
        function CreateHeaderAndFooter(tableId, data) {

            // 產生標頭欄位List
            let header = Object.keys(data);
            let headerList = $.map(header, function (item) { return item; });
            //headerList.unshift('功能'); // 從list前端加入元素

            //-----------------------------------------------------------------

            // 將標頭欄位list綁訂到htmltable的thead
            $(`${tableId}`).append('<thead></thead>');
            $(`${tableId} > thead`).append('<tr></tr>');
            $.each(headerList, function (i, v) {
                $(`${tableId} > thead > tr`).append(`<th>${v}</th>`);
            });

            //-----------------------------------------------------------------

            // 將標頭欄位list綁訂到htmltable的tfoot
            $(`${tableId}`).append('<tfoot></tfoot>');
            $(`${tableId} > tfoot`).append('<tr></tr>');
            $.each(headerList, function (i, v) {
                $(`${tableId} > tfoot > tr`).append(`<th>${v}</th>`);
            });

            //-----------------------------------------------------------------

            return headerList;
        } // end CreateHeader

        // 建立 DataTable 欄位屬性
        function CreateDataTableColumns(headerList) {
            let DataTableColumns = $.map(headerList, function (item, index) {
                /*
                if (item == '功能') {
                    item = {
                        "render": function (data, type, row, meta) {
                            data = `<a style='font-size: 20px;' class='btnShowStuDetailData' sid='${row['SID']}' >查看學生詳細資料</a>`;
                            return data;
                        }
                    };
                } else {
                    item = { "data": item };
                }
                */

                item = { "data": item };
                return item;
            });

            return DataTableColumns;
        } // end CreateDataTableColumns

        function Init_DataList() {
            let Method = 'GetDataList';
            let url = `/api/_SubjectManagement.ashx?Method=${Method}`;
            let response = CallAPI(url);

            let isSuccess = response['isSuccess'];
            if (!isSuccess) {
                if (Msg == 'logout') {
                    GoToDefaultPage();
                } else {
                    alert(Msg);
                    return false;
                }
            }

            let result = response['Data'];
            if (result == [] || result.length == 0) {
                alert('無資料');
                return false;
            } else {
                let headerList = CreateHeaderAndFooter('#DataList', result[0]);
                var DataTableColumns = CreateDataTableColumns(headerList);
            }

            let MyTable = $('#DataList').DataTable({
                lengthMenu: [
                    [5, 10, 25, 50, 100],    // 實際值
                    [5, 10, 25, 50, 100]     // 顯示用
                ],
                pageLength: 5,
                columnDefs: [
                    //{ targets: 0, visible: false, searchable: false } // 隱藏的欄位不會被搜尋
                ],
                //order: [[2, "desc"]], // 使用第[2]個欄位 遞減排序
                data: result,
                columns: DataTableColumns,
            }); // end $('#DataList').DataTable

        } // end Init_DataList

    </script>

</head>
<body>
    <form id="form1" runat="server">
        <div>
            <div>
                <h1>科目管理</h1>
                <hr />
                <table id="DataList" class="display" style="width: 100%"></table>
                <hr />
            </div>

            <div>
                <h1>新增科目</h1>
                <span>科目名稱 </span>
                <input id="SubjectName" />
                <input id="btnCreate" type="button" value="新增" />
            </div>
        </div>
    </form>
</body>
</html>
