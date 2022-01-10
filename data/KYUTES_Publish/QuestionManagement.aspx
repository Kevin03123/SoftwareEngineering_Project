<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="QuestionManagement.aspx.cs" Inherits="KYUTES.QuestionManagement" %>

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

        /* 要加這一行，各欄位得搜尋輸入框才會跑到table的頂部 */
            .display tfoot {
                display: table-header-group;
            }
    </style>
    <link href="https://cdn.datatables.net/1.10.20/css/jquery.dataTables.min.css" rel="stylesheet" />

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.20/js/jquery.dataTables.min.js"></script>
    <script src="Scripts/Common.js"></script>

    <script>
        function Init_Block() {
            $('.Create').show();
            $('.Update').hide();
        }

        function Init_LevelList() {
            let Method = 'GetLevelList';
            let url = `/api/_QuestionManagement.ashx?Method=${Method}`;
            let result = CallAPI(url);

            let isSuccess = result['isSuccess'];

            if (isSuccess) {
                $('#Level').empty();

                let data = result['Data']
                $.each(data, function (idx, val) {
                    $('#Level').append(`<option value='${val['id']}'>${val['Descript']}</option>`);
                });
            } else {
                if (Msg == 'logout') {
                    GoToDefaultPage();
                } else {
                    alert(Msg);
                }
            }
        } // end Init_LevelList

        function Init_SubjectList() {
            let Method = 'GetSubjectList';
            let url = `/api/_QuestionManagement.ashx?Method=${Method}`;
            let result = CallAPI(url);

            let isSuccess = result['isSuccess'];

            if (isSuccess) {
                $('#Subject').empty();

                let data = result['Data']
                $.each(data, function (idx, val) {
                    $('#Subject').append(`<option value='${val['id']}'>${val['SubjectName']}</option>`);
                });
            } else {
                if (Msg == 'logout') {
                    GoToDefaultPage();
                } else {
                    alert(Msg);
                }
            }
        } // end Init_SubjectList

        $(document).ready(function () {
            Init_Block();
            Init_DataList();
            Init_SubjectList();
            Init_LevelList();
            SetListener();
        });

        function SetListener() {
            $('#btnCreate').click(function () {
                let flag = confirm('確定要新增嗎？');
                if (!flag) { return false; }

                CreateQuestion();
            });

            $('#CreateOrUpdateQuestion').change(function () {
                let action = $(this).val();

                if (action == 'c') {
                    $('.Create').show();
                    $('.Update').hide();
                } else if (action == 'u') {
                    $('.Update').show();
                    $('.Create').hide();

                    Init_QuestionIdList();
                }
            });

            $('#QuestionId').change(function () {
                let QId = $(this).val();
                SetQuestionBlock(QId);
            });

            $('#btnUpdate').click(function () {
                let flag = confirm('確定要更新嗎？');
                if (!flag) { return false; }

                UpdateQuestion();
            });

        } // end SetListener

        function UpdateQuestion() {

            let QId = $('#QuestionId').val();
            let SubjectId = $('#Subject').val();
            let Level = $('#Level').val();
            let Question = $('#Question').val();
            let Ans = $('#Ans').val();

            let Method = 'UpdateQuestion';
            let url = `/api/_QuestionManagement.ashx?Method=${Method}`;
            let Parameters = { QId: QId, Question: Question, Ans: Ans, Level: Level, SubjectId: SubjectId };

            let result = CallAPI(url, Parameters);
            let isSuccess = result['isSuccess'];
            let Msg = result['Msg'];

            if (isSuccess) {
                alert('更新成功');
                location.reload();
            } else {
                if (Msg == 'logout') {
                    GoToDefaultPage();
                } else {
                    alert(Msg);
                }
            }
        }

        function SetQuestionBlock(QId) {
            let Method = 'GetQuestionInfo';
            let url = `/api/_QuestionManagement.ashx?Method=${Method}`;
            let Parameters = { QId: QId };

            let result = CallAPI(url, Parameters);
            let isSuccess = result['isSuccess'];
            let Msg = result['Msg'];

            if (isSuccess) {
                let qInfo = result['Data'];

                let SubjectId = qInfo['SubjectId'];
                let Level = qInfo['Level'];
                let Question = qInfo['Question'];
                let Ans = qInfo['Ans'];

                $("#Subject").val(SubjectId);
                $("#Level").val(Level);
                $("#Question").val(Question);
                $("#Ans").val(Ans);
            } else {
                if (Msg == 'logout') {
                    GoToDefaultPage();
                } else {
                    alert(Msg);
                }
            }
        } // end SetQuestionBlock

        function Init_QuestionIdList() {
            let Method = 'GetQuestionIdList';
            let url = `/api/_QuestionManagement.ashx?Method=${Method}`;
            let result = CallAPI(url);

            let isSuccess = result['isSuccess'];

            if (isSuccess) {
                $('#QuestionId').empty();

                let data = result['Data'];
                $.each(data, function (idx, val) {
                    $('#QuestionId').append(`<option value='${val['id']}'>${val['id']}</option>`);
                });
            } else {
                if (Msg == 'logout') {
                    GoToDefaultPage();
                } else {
                    alert(Msg);
                }
            }
        } // end Init_QuestionIdList

        function CreateQuestion() {

            let SubjectId = $('#Subject').val();
            let Level = $('#Level').val();
            let Question = $('#Question').val();
            let Ans = $('#Ans').val();

            let Method = 'CreateQuestion';
            let url = `/api/_QuestionManagement.ashx?Method=${Method}`;
            let Parameters = { Question: Question, Ans: Ans, Level: Level, SubjectId: SubjectId };

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
        } // end CreateQuestion

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
            let url = `/api/_QuestionManagement.ashx?Method=${Method}`;
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
                order: [[0, "desc"]], // 使用第[0]個欄位 遞減排序
                data: result,
                columns: DataTableColumns,
            }); // end $('#DataList').DataTable

            //---------------------------------------------------------------------------------------------------------------

            // 建立各欄位搜訊模組

            // 參考網址 https://jsfiddle.net/dipakthoke07/ehhfsrfq/2/
            // Setup - add a text input to each footer cell
            $('#DataList tfoot th').each(function () {
                let title = $(this).text();
                if (title == '選取') {
                    //$(this).html(`<input disabled='disabled' style='width:100%;'/>`);
                    $(this).html(``);
                } else {
                    $(this).html(`<input type='text' style='width:100%;' placeholder='Search...'/>`);
                }
            });

            // Apply the search
            MyTable.columns().every(function () {
                let that = this;

                $('input', this.footer()).on('keyup change', function () {
                    if (that.search() !== this.value) {
                        that.search(this.value).draw();
                    }

                    // 依據輸入的值，動態改變搜尋輸入框的寬度
                    // 參考網址 http://jsfiddle.net/nrabinowitz/NvynC/
                    $(this).attr('size', $(this).val().length);
                });
            });

        } // end Init_DataList

    </script>

</head>
<body>
    <form id="form1" runat="server">
        <div>
            <div>
                <h1>題目管理</h1>
                <hr />
                <table id="DataList" class="display" style="width: 100%"></table>
                <hr />
            </div>

            <div>

                <h1>
                    <span>請選擇操作類型: </span>
                    <select id="CreateOrUpdateQuestion" style="font-size: x-large;">
                        <option value="c">新增題目</option>
                        <option value="u">更新題目</option>
                    </select>
                </h1>

                <p class="Update">
                    <span>題目編號 </span>
                    <select id="QuestionId" class="Update"></select>
                </p>

                <span>科目類型 </span>
                <select id="Subject"></select>

                <span>難易度 </span>
                <select id="Level"></select>
                <br />
                <br />

                <span>題目 </span>
                <textarea id="Question" placeholder="上限500字..."></textarea>

                <span>答案 </span>
                <select id="Ans">
                    <option value="A">A</option>
                    <option value="B">B</option>
                    <option value="C">C</option>
                    <option value="D">D</option>
                </select>
                <br />
                <br />

                <input id="btnCreate" type="button" value="新增" class="Create" />
                <input id="btnUpdate" type="button" value="更新" class="Update" />
            </div>

        </div>
    </form>
</body>
</html>
