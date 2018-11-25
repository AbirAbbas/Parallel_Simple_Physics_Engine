__kernel void phys(__global float * moveBall,
                   __global float * result_array, int arr_size, __global int * index_array) {
    
    int id = get_global_id(0);
    
    float our_value = moveBall[index_array[id]];
    float our_value2 = moveBall[index_array[id] + 1];
    int x = id % arr_size;
    int y = id / arr_size;
    barrier(CLK_LOCAL_MEM_FENCE);
    printf("%2.f\n", our_value);
    
}

/*
__kernel void add_numbers(__global float4* data,
      __local float* local_result, __global float* group_result) {

   float sum;
   float4 input1, input2, sum_vector;
   uint global_addr, local_addr;

   global_addr = get_global_id(0) * 2;
   input1 = data[global_addr];
   input2 = data[global_addr+1];
   sum_vector = input1 + input2;

   local_addr = get_local_id(0);
   local_result[local_addr] = sum_vector.s0 + sum_vector.s1 + 
                              sum_vector.s2 + sum_vector.s3; 
   barrier(CLK_LOCAL_MEM_FENCE);

   if(get_local_id(0) == 0) {
      sum = 0.0f;
      for(int i=0; i<get_local_size(0); i++) {
         sum += local_result[i];
      }
      group_result[get_group_id(0)] = sum;
 
 
 n = 0 { 0 1
 
 1   4 5
 
 
   }
}*/
