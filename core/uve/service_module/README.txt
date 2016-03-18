服务模块(Service Module)必须实现以下三个方法

/**
 * 返回控制数据, 数据结构如下:
 * {
 *      "limited": boolean,
 *      "reason": "", //e.g. cpm_limit
 * }
 */
function ctrl();

/**
 * 返回如下数据结构:
 * {
 *      "data": {},
 *      "type": "trend|ad",
 *      "error": "",
 *      "errno": int,
 *      "meta": {}
 * }
 */
function run();


/**
 * 保存上下文数据
 */
function finish();

