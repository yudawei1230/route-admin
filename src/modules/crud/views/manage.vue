<template>
	<cl-crud ref="Crud">
		<cl-row>
			<!-- 刷新按钮 -->
			<cl-refresh-btn />
			<!-- 新增按钮 -->
			<cl-add-btn />
			<!-- 删除按钮 -->
			<cl-multi-delete-btn />
			<cl-flex1 />
			<!-- 关键字搜索 -->
			<cl-search-key />
		</cl-row>

		<cl-row>
			<!-- 数据表格 -->
			<cl-table ref="Table"> </cl-table>
		</cl-row>

		<cl-row>
			<cl-flex1 />
			<!-- 分页控件 -->
			<cl-pagination />
		</cl-row>

		<!-- 新增、编辑 -->
		<cl-upsert ref="Upsert" :onSubmit="onSubmit" />
		<!-- 新增、编辑 -->
		<cl-form ref="UpsertCode" />
	</cl-crud>
</template>

<script lang="ts" name="crud-manage" setup>
import { ref } from 'vue'
import { cloneDeep } from "lodash-es";
import { useCrud, useTable, useUpsert } from "@cool-vue/crud";
import { useCool } from "/@/cool";
import copy from "copy-to-clipboard";
import { ElMessage } from "element-plus";
import { useDict } from "/$/dict";

const { service } = useCool();

// 字典
const { dict } = useDict();

const defaultCode = `
function handler(data) {
	// 关键词
  const keyword = "keywords=" + encodeURIComponent(data.keyword);
	// 关键词前缀
  const sprefix = "sprefix=" + encodeURIComponent(data.keyword + ',aps,366');
	// 排名
  const rank = "sr=" + data.rank;
	// 时间戳
	const timestamp = "qid=" + (Date.now() / 1000).toFixed(0)

	// 跳转链接
  const path = [data.redirectUrl, keyword, timestamp, sprefix, rank].join('&') + 'th=1'

  return path;
}
`


// cl-upsert
const UpsertCode = ref()
const UpsertCodeItems = [
	{
		prop: "routeCode",
		label: "路由代码",
		component: { name: "cl-editor-monaco", props: { language: 'typescript' } },

	}
]

// cl-upsert
const Upsert = useUpsert({
	items: [
		{ prop: "customerName", label: "客户名", required: true, component: { name: "el-input" } },
		{ prop: "shortLinkName", label: "短链名", required: true, component: { name: "el-input" } },
		{ prop: "shortLinkId", label: "短链ID", required: true, component: { name: "el-input" } },
		{
			prop: "redirectUrl",
			label: "跳转链接",
			component: { name: "el-input" },
			required: true
		},

		{ 
			prop: "keyword",
			label: "关键词",
			hook: {
				bind: "string"
			},
			component: {
				name: "el-select",
				options: dict.get("keyword"),
				props: { filterable: true }
			}},
		{ prop: "rank", label: "排名", required: true, component: { name: "el-input" } },
	]
});

// cl-table
const Table = useTable({
	columns: [
		{ type: "selection" },
		// { prop: "id", label: "ID" },
		{ prop: "customerName", label: "客户名" },
		{ prop: "shortLinkName", label: "短链名" },
		{ prop: "shortLinkId", label: "短链id" },
		// { prop: "redirectUrl", label: "跳转链接"},
		{ 
			prop: "keyword",
			label: "关键词",
			dict: dict.get("keyword"),
			dictColor: false
		},
		{ prop: "rank", label: "排名" },
		{ prop: "jumpCount", label: "跳转次数" },
		// { prop: "createTime", label: "创建时间", sortable: "desc", width: 160 },
		{ prop: "updateTime", label: "更新时间", sortable: "custom", width: 160 },
		{ type: "op", buttons: [
			"edit",
			"delete",
			{
				label: "复制短链",
				type: "success",
				onClick({ scope }) {
					copy(`http://8.218.88.234:8001/${scope.row.shortLinkId}`);
					ElMessage.success("短链复制成功");
				}
			},
			{
				label: "修改路由",
				type: "default",
				onClick({ scope }) {
					//UpsertCode.value.edit(scope.row)
					// config.items[0].routeCode = scope.row.routeCode
					UpsertCode.value?.open(
						{
							title: '修改路由',
							// dialog: config.dialog,
							items: cloneDeep(UpsertCodeItems),
							on: {
								submit(data) {
									Upsert.value.mode = 'update'
									Upsert.value.submit({ ...scope.row, routeCode: data.routeCode })
									UpsertCode.value.close()
								}
							},
							form: {
								routeCode: scope.row.routeCode
							},
							_data: {}
						}
					);
				}
			},
		], width: 300 }
	]
});

// cl-crud
const Crud = useCrud(
	{
		service: service.crud.manage
	},
	(app) => {
		app.refresh();
	}
);

const onSubmit = async (data, { next, close }) => {
	if(!data.routeCode) data.routeCode = defaultCode
	const res = await service.crud.manage.page()
	
	if(!data.id) {
		const maxLink = await service.request({
			url: '/admin/base/sys/param/findParam',
			method: "GET",
			params: { key: 'maxLinkNum' }
		})
		if(res.pagination.total >= Number(maxLink.data)) {
			ElMessage.error('超出最大短链数量')
			close()
			throw new Error('max')
		}
	}
	next(data)
}
</script>
