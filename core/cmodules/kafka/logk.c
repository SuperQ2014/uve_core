/**
 * @author Yangyang<yangyang21@staff.weibo.com>
 */
#include <math.h>
#include <luajit.h>
#include <lauxlib.h>
#include <lualib.h>
#include <ctype.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <syslog.h>
#include <errno.h>
#include <librdkafka/rdkafka.h>  // Kafka



static void msg_delivered (rd_kafka_t *rk,
               void *payload, size_t len,
               int error_code,
               void *opaque, void *msg_opaque) {

    if (error_code)
        fprintf(stderr, 
            "[RDKAFKA]%% Message delivery failed: %s\n",
            rd_kafka_err2str(error_code));
    else{
//        fprintf(stderr, "[RDKAFKA]%% Message delivered (%zd bytes)\n", len);
  }
}


void* create_kafka_m(const char* brokers)
{
    char errstr[512] = "";
    char tmp[16] = "";
    rd_kafka_t *rk;
    rd_kafka_conf_t *conf;

    conf = rd_kafka_conf_new();

    rd_kafka_conf_set_dr_cb(conf, msg_delivered);

    snprintf(tmp, sizeof(tmp), "%i", SIGIO);
    rd_kafka_conf_set(conf, "internal.termination.signal", tmp, NULL, 0);

    
    if (!(rk = rd_kafka_new(RD_KAFKA_PRODUCER, conf, errstr, sizeof(errstr)))) {
        fprintf(stderr, "[RDKAFKA]%% Failed to create new producer: %s\n", errstr);
        exit(1);
    }

    if (rd_kafka_brokers_add(rk, brokers) == 0) {
        fprintf(stderr, "[RDKAFKA]%% No valid brokers specified\n");
        exit(1);
    }

    return (void *)rk;
}

void* create_kafka_topic_m(const char * topic, void * rk_void)
{

    rd_kafka_t * rk = (rd_kafka_t *)(rk_void);
    rd_kafka_topic_conf_t *topic_conf = rd_kafka_topic_conf_new();
    rd_kafka_topic_t *rkt = rd_kafka_topic_new(rk, topic, topic_conf);
    return (void *)rkt;
}

void destory_kafka_m(void * rk_void)
{  
    rd_kafka_t * rk = (rd_kafka_t * )rk_void;
    while (rd_kafka_outq_len(rk) > 0){
        rd_kafka_poll(rk, 100);
    }
    rd_kafka_destroy(rk);
}


void kafka_log_m(void* rkt_void, void* rk_void, int partition,const char * buf)
{
    rd_kafka_topic_t *rkt = (rd_kafka_topic_t *)rkt_void;
    rd_kafka_t *rk = (rd_kafka_t *)rk_void; 
    size_t len = strlen(buf); 
    if(rd_kafka_produce(rkt, partition,
                        RD_KAFKA_MSG_F_COPY,                                                                  
                        buf, len,
                        NULL, 0,
                        NULL) == -1) 
    {
         fprintf(
             stderr ,
             "[RDKAFKA]%% Failed to produce to topic %s "
             "partition %i: %s meeage: %s\n",
             rd_kafka_topic_name(rkt), 
             partition,
             rd_kafka_err2str(rd_kafka_errno2err(errno)),
             buf
             );
   }
   rd_kafka_poll(rk, 0);
}

static int klog(lua_State *L)
{
    void *rkt_void = (void *)lua_topointer(L, 1);
    void *rk_void = (void *)lua_topointer(L, 2);
    int p = lua_tonumber(L, 3);
    const char * str = lua_tostring(L, 4);
    kafka_log_m(rkt_void, rk_void, -1, str);
}

static int create_kafka(lua_State *L)
{
    const char * brokers = lua_tostring(L, 1);
    void * r = create_kafka_m(brokers);
    lua_pushlightuserdata(L, r);
    return 1;
}

static int create_topic(lua_State *L)
{
    const char * topic = lua_tostring(L, 1);
    void * rt_void = (void *)lua_topointer(L, 2);
    void * r = create_kafka_topic_m(topic, rt_void);
    lua_pushlightuserdata(L, r);
    return 1;
}

static int destory_kafka(lua_State *L)
{
    void * rt_void = (void *)lua_topointer(L, 1);
    destory_kafka_m(rt_void);
    return 0;
}

static int help(lua_State *L)
{
  printf("connect with yangyang21");
  return 0;
}


static const struct luaL_Reg logk_lib[] = {
    {"create_kafka" , create_kafka},
    {"create_topic", create_topic},
    {"destory_kafka", destory_kafka},
    {"klog", klog},
    {"help", help},
    {NULL, NULL}
};

int luaopen_liblogk(lua_State *L){
//    luaL_newlib(L, logk_lib);
    luaL_register(L, "logk_lib", logk_lib);
    return 1;
}
