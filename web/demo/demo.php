<?php

echo json_encode(array(
    'errno' => 0,
    'error' => '',
    'data' => array(
        array(
            'name' => 'James',
            'age' => '27',
            '_service_module' => isset($_GET['service_module']) ? $_GET['service_module'] : '',
        ),
    )
));
