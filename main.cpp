#include <google/protobuf/struct.pb.h>
#include <iostream>

int main()
{
    auto msg = google::protobuf::Struct{};
    auto value = google::protobuf::Value{};
    value.set_string_value("b");
    (*msg.mutable_fields())["a"] = value; // error here

    std::cout << msg.fields().at("a").string_value() << '\n';
}
