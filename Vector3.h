struct Vector3{
  float x;
  float y;
  float z;

  Vector3();
  Vector3(float x, float y, float z);
  ~Vector3();
};

Vector3::Vector3() {}
Vector3::Vector3(float x, float y, float z) : x(x), y(y), z(z) {}
Vector3::~Vector3() {}