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
			<cl-table ref="Table" />
		</cl-row>

		<cl-row>
			<cl-flex1 />
			<!-- 分页控件 -->
			<cl-pagination />
		</cl-row>

		<!-- 新增、编辑 -->
		<cl-upsert ref="Upsert" />
	</cl-crud>
</template>

<script lang="ts" name="crud-manage" setup>
import { useCrud, useTable, useUpsert } from "@cool-vue/crud";
import { useCool } from "/@/cool";

const { service } = useCool();

// cl-upsert
const Upsert = useUpsert({
	items: [
		{ prop: "customerName", label: "客户名", required: true, component: { name: "el-input" } },
		{ prop: "shortLinkName", label: "短链名", required: true, component: { name: "el-input" } },
		{
			prop: "redirectUrl",
			label: "跳转链接",
			component: { name: "el-input" },
			required: true
		},
		{ prop: "keyword", label: "关键词", required: true, component: { name: "el-input" } },
		{ prop: "rank", label: "排名", required: true, component: { name: "el-input" } },
		{
			prop: "routeCode",
			label: "路由代码",
			component: { name: "cl-editor-monaco" }
		}
	]
});

// cl-table
const Table = useTable({
	columns: [
		{ type: "selection" },
		{ prop: "id", label: "ID" },
		{ prop: "customerName", label: "客户名" },
		{ prop: "shortLinkName", label: "短链名" },
		{ prop: "shortLinkId", label: "短链id" },
		{ prop: "redirectUrl", label: "跳转链接"},
		{ prop: "keyword", label: "关键词" },
		{ prop: "rank", label: "排名" },
		{ prop: "jumpCount", label: "跳转次数" },
		{ prop: "createTime", label: "创建时间", sortable: "desc", width: 160 },
		{ prop: "updateTime", label: "更新时间", sortable: "custom", width: 160 },
		{ type: "op", buttons: ["edit", "delete"] }
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
</script>
