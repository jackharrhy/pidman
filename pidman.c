#define INT_SIZE 32
#define MIN_PID 1
#define MAX_PID 1000
#define TOTAL_PIDS (MAX_PID - MIN_PID)

#define CEILING(x, y) (((x) + (y)-1) / (y))
#define MAP_SIZE CEILING(TOTAL_PIDS, INT_SIZE)

int PID_MAP[MAP_SIZE];
int CUR_FREE_PID = MIN_PID;

int allocate_pid();
void release_pid(int pid);

struct bitmap_ops {
  int index;
  int pos;
  unsigned int flag;
};

struct bitmap_ops make_bitmap_ops(int offset) {
  struct bitmap_ops temp;
  temp.index = offset / INT_SIZE;
  temp.pos = offset % INT_SIZE;
  temp.flag = 1;
  temp.flag = temp.flag << temp.pos;
  return temp;
}

int get_bit(int offset) {
  struct bitmap_ops ops = make_bitmap_ops(offset);
  if (PID_MAP[ops.index] & ops.flag) {
    return 1;
  } else {
    return 0;
  }
}

void set_bit(int offset, int value) {
  struct bitmap_ops ops = make_bitmap_ops(offset);

  if (value == 0) {
    ops.flag = ~ops.flag;
    PID_MAP[ops.index] = PID_MAP[ops.index] & ops.flag;
  } else {
    PID_MAP[ops.index] = PID_MAP[ops.index] | ops.flag;
  }
}

// Allocates and returns a pid, returns -1 if unable to allocate
int allocate_pid(void) {
  if (CUR_FREE_PID > MAX_PID)
    return -1;

  set_bit(CUR_FREE_PID - MIN_PID, 1);

  int pid = CUR_FREE_PID;
  int next_free_pid = CUR_FREE_PID + 1;

  while (next_free_pid < MAX_PID) {
    if (get_bit(next_free_pid - MIN_PID) == 0) {
      break;
    }
    next_free_pid += 1;
  }
  CUR_FREE_PID = next_free_pid;

  return pid;
}

// Releases a pid
void release_pid(int pid) {
  if (!(pid < MIN_PID || pid > MAX_PID)) {
    int offset = pid - MIN_PID;
    set_bit(offset, 0);

    if (pid < CUR_FREE_PID)
      CUR_FREE_PID = pid;
  }
}
