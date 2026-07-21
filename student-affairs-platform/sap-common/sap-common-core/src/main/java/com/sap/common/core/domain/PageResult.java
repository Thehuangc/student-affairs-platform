package com.sap.common.core.domain;

import lombok.Data;

import java.io.Serializable;
import java.util.List;

/**
 * 分页结果
 */
@Data
public class PageResult<T> implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 总记录数
     */
    private long total;

    /**
     * 列表数据
     */
    private List<T> rows;

    /**
     * 当前页码
     */
    private long pageNum;

    /**
     * 每页数量
     */
    private long pageSize;

    public PageResult() {
    }

    public PageResult(long total, List<T> rows) {
        this.total = total;
        this.rows = rows;
    }

    public PageResult(long total, List<T> rows, long pageNum, long pageSize) {
        this.total = total;
        this.rows = rows;
        this.pageNum = pageNum;
        this.pageSize = pageSize;
    }
}
