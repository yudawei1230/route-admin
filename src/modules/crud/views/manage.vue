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
import { ref, computed } from 'vue'
import { cloneDeep } from "lodash-es";
import { useCrud, useTable, useUpsert } from "@cool-vue/crud";
import { useCool } from "/@/cool";
import copy from "copy-to-clipboard";
import { ElMessage } from "element-plus";
import { useDict } from "/$/dict";

const { service } = useCool();

// 字典
const { dict } = useDict();

const defaultCode = undefined


// cl-upsert
const UpsertCode = ref()
const UpsertCodeItems = [
	{
		prop: "routeCode",
		label: "路由代码",
		component: { name: "cl-editor-monaco", props: { language: 'typescript' } },

	}
]
const keyword = computed(() => {
	const list = dict.get("keyword").value
	if(!Array.isArray(list) || !list.length) return []
	return list.map(v => {
		v.value = String(v.id)
		return v
	})
})
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
			prop: "brand",
			label: "品牌名",
			component: { name: "el-input" },
			required: true
		},
		{ 
			prop: "keyword",
			label: "关键词",
			hook: {
				bind: "string"
			},
			required: true,
			component: {
				name: "el-select",
				options: keyword,
				props: { filterable: true }
			}}
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
		{ prop: "brand", label: "品牌" },
		// { prop: "redirectUrl", label: "跳转链接"},
		{ 
			prop: "keyword",
			label: "关键词",
			dict: keyword,
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
					copy(`${location.origin.includes('localhost') ? 'http://localhost:8001  ' : location.origin.replace(/\:\d+/, '')}/${scope.row.shortLinkId}`);
					ElMessage.success("短链复制成功");
				}
			},
			// {
			// 	label: "修改路由",
			// 	type: "default",
			// 	onClick({ scope }) {
			// 		//UpsertCode.value.edit(scope.row)
			// 		// config.items[0].routeCode = scope.row.routeCode
			// 		UpsertCode.value?.open(
			// 			{
			// 				title: '修改路由',
			// 				// dialog: config.dialog,
			// 				items: cloneDeep(UpsertCodeItems),
			// 				on: {
			// 					submit(data) {
			// 						Upsert.value.mode = 'update'
			// 						Upsert.value.submit({ ...scope.row, routeCode: data.routeCode })
			// 						UpsertCode.value.close()
			// 					}
			// 				},
			// 				form: {
			// 					routeCode: scope.row.routeCode
			// 				},
			// 				_data: {}
			// 			}
			// 		);
			// 	}
			// },
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
	if(!data.rank) data.rank = ''
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
